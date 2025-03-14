#!/bin/bash
##
## Generate Linux iproute command-line from legacy net-tools command-line
## netstat(8) to ip(8) and ss(8) converter
## Copyright (c) 2013-2019 SATOH Fumiyasu @ OSS Technology Corp., Japan
##
## License: GNU General Public License version 3
##

set -u

perr() {
  echo "$0: ERROR: $1" 1>&2
}

pdie() {
  perr "$1"
  exit "${2-1}"
}

run() {
  [[ -z ${exec_only_flag-} ]] && echo "$@"
  [[ -n ${exec_flag-} ]] && { "$@" || exit $?; }
}

run_ip()
{
  run ip ${resolve_flag:+-r} "$@" ${ip_opts+"${ip_opts[@]}"}
}

run_ss()
{
  run ss ${resolve_flag+-r} "$@" ${ss_opts+"${ss_opts[@]}"}
}

require_value()
{
  local name="$1"; shift

  if [[ $# -eq 0 ]]; then
    pdie "$name: Requires value"
  fi

  local value="$1"; shift

  if [[ $# -gt 0 ]]; then
    if [[ $value =~ $1 ]]; then
      : OK
    else
      pdie "$name: Invalid value: $value"
    fi
  fi
}

## ======================================================================

resolve_flag="set"
continuous_flag=""
run_cmd="run_ss"

ss_opts=()
common_opts=()

case "${0%.bash}" in
*2)
  ;;
*)
  if [ -z "${NETSTAT2_FORCE_RUN+set}" ] && [ -x /bin/netstat ]; then
    exec /bin/netstat "$@"
    exit $?
  fi
  exec_flag="set"
  exec_only_flag="set"
  ;;
esac

while [[ $# -gt 0 ]]; do
  opt="$1"; shift

  case "$opt" in
  -[a-zA-Z0-9]?*)
    set -- "-${opt:2}" "$@"
    opt="${opt:0:2}"
    ;;
  --*=*)
    set -- "-${opt#*=}" "$@"
    opt="${opt%%=*}"
    ;;
  esac

  case "$opt" in
  --x)
    exec_flag="set"
    ;;
  --xx)
    exec_flag="set"
    exec_only_flag="set"
    ;;
  -a|--all|-e|--extended|-o|-p)
    ss_opts+=("$opt")
    ;;
  -n|--numeric)
    ss_opts+=("$opt")
    unset resolve_flag
    ;;
  --timers)
    ss_opts+=(--options)
    ;;
  --program)
    ss_opts+=(--process)
    ;;
  -t|--tcp|-u|--udp|-w|--raw|-x|--unix|-l|--listening)
    ss_opts+=("$opt")
    ;;
  -A|--protocol)
    require_value "$opt" ${1+"$1"}
    arg="$1"; shift
    case "$arg" in
    unix)
      ss_opts+=(-f "$arg")
      ;;
    inet|inet6)
      common_opts+=(-f "$arg")
      ;;
    *)
      pdie "$opt $arg: Not supported"
      ;;
    esac
    ;;
  -4|--inet)
    common_opts+=(-4)
    ;;
  -6|--inet6)
    common_opts+=(-6)
    ;;
  -c|--continuous)
    continuous_flag="set"
    ;;
  -i|--interfaces)
    run_cmd="run_ip"
    ip_opts=(-s link)
    ;;
  -r|--route)
    run_cmd="run_ip"
    ip_opts=(route)
    ;;
  -g|--groups)
    run_cmd="run_ip"
    ip_opts=(maddr)
    ;;
  -F|-C|-M|--masquerade|-s|--statistics)
    ## FIXME
    pdie "$opt: Not supported yet"
    ;;
  -v|--verbose|-W|--wide|--numeric-hosts|--numeric-ports|--numeric-users)
    ## Ignore
    ;;
  --ipx|--ax25|--netrom|--ddp)
    pdie "$opt: Not supported"
    ;;
  --)
    shift
    break
    ;;
  -*)
    pdie "Unknown option: $opt"
    ;;
  *)
    break
    ;;
  esac
done

while :; do
  $run_cmd ${common_opts+"${common_opts[@]}"}
  run_result="$?"
  if [[ -z ${continuous_flag-} ]] || [[ -z ${exec_flag-} ]]; then
    exit "$run_result"
  fi
  exec_only_flag="set"
  sleep 1
done

exit 0
