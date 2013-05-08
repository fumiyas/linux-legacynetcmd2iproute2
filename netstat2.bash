#!/bin/bash
##
## Convert to Linux iproute2 command-line from legacy networking command-line
## netstat(8) to ip(8) and ss(8) converter
## Copyright (c) 2013 SATOH Fumiyasu @ OSS Technology Corp., Japan
##
## License: GNU General Public License version 3
##

set -u

perr() {
  echo "$0: ERROR: $1" 1>&2
}

pdie() {
  perr "$1"
  exit ${2-1}
}

run() {
  [[ -z ${exec_only_flag-} ]] && echo "$@"
  [[ -n ${exec_flag-} ]] && { "$@" || exit $?; }
}

run_ss()
{
  run ss ${resolve_flag+-r} "$@"
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
ss_opts=()

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
  -a|--all|-e|--extended|-o|-p|-4|-6)
    ss_opts[${#ss_opts[@]}]="$opt"
    ;;
  -n|--numeric)
    ss_opts[${#ss_opts[@]}]="$opt"
    unset resolve_flag
    ;;
  --timers)
    ss_opts[${#ss_opts[@]}]="--options"
    ;;
  --program)
    ss_opts[${#ss_opts[@]}]="--process"
    ;;
  -t|--tcp|-u|--udp|-w|--raw|-x|--unix|-l|--listening)
    ss_opts[${#ss_opts[@]}]="$opt"
    ;;
  -A|--protocol)
    require_value "$opt" ${1+"$1"}
    arg="$1"; shift
    case "$arg" in
    unix|inet|inet6)
      ;;
    *)
      pdie "$opt $arg: Not supported"
      ;;
    esac
    ss_opts[${#ss_opts[@]}]="-f"
    ss_opts[${#ss_opts[@]}]="$arg"
    ;;
  --inet)
    ss_opts[${#ss_opts[@]}]="-4"
    ;;
  --inet6)
    ss_opts[${#ss_opts[@]}]="-6"
    ;;
  -c|--continuous)
    continuous_flag="set"
    ;;
  -r|--route|-F|-C|-g|--groups|-i|--interfaces|-M|--masquerade|-s|--statistics)
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

if [[ -n ${continuous_flag-} ]] && [[ -n ${exec_flag-} ]]; then
  while :; do
    run_ss ${ss_opts+"${ss_opts[@]}"}
    exec_only_flag="set"
    sleep 1
  done
  exit 0
fi

run_ss ${ss_opts+"${ss_opts[@]}"}

