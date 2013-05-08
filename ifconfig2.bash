#!/bin/bash
##
## Convert to Linux iproute2 command-line from legacy networking command-line
## ifconfig(8) to ip(8) converter
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

run_ip()
{
  run ip ${resolve_flag:+-r} ${af:+-f "$af"} "$@"
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

resolve_flag=""

case "${0%.bash}" in
*2)
  ;;
*)
  exec_flag="set"
  exec_only_flag="set"
  ;;
esac

while [[ $# -gt 0 ]]; do
  case "${1-}" in
  --x)
    exec_flag="set"
    ;;
  --xx)
    exec_flag="set"
    exec_only_flag="set"
    ;;
  -a|-s|-v)
    ## Ignore
    ;;
  --)
    shift
    break
    ;;
  -*)
    pdie "Unknown option: $1"
    ;;
  *)
    break
    ;;
  esac
  shift
done

if [[ $# -eq 0 ]]; then
  run ip address
  exit 1
fi

if="${1-}"; shift

if [[ $# -eq 0 ]]; then
  run ip address show dev "$if"
  exit $?
fi

case "$1" in
inet|inet6)
  af="$1"
  shift
  ;;
unix|ax25|netrom|rose|ipx|ddp|ec|ashx25)
  pdie "$1: Not supported"
  ;;
esac

while [[ $# -gt 0 ]]; do
  cmd="$1"; shift
  case "$cmd" in
  up)
    run_ip link set up dev "$if"
    ;;
  down)
    run_ip link set down dev "$if"
    ;;
  arp|dynamic|multicast|promisc|trailers)
    run_ip link set "$cmd" on dev "$if"
    ;;
  -arp|-dynamic|-multicast|-promisc|-trailers)
    run_ip link set "${cmd#-}" off dev "$if"
    ;;
  allmulti)
    run_ip link set allmulticast on dev "$if"
    ;;
  -allmulti)
    run_ip link set allmulticast off dev "$if"
    ;;
  pointopoint|-pointopoint|dstaddr|tunnel|outfill|keepalive|metric)
    ## FIXME: ip route?
    pdie "$cmd: Not supported yet"
    ;;
  mem_start|io_addr|irq|media)
    ## FIXME: ethtool?
    pdie "$cmd: Not supported yet"
    ;;
  *.*.*.*|*::*)
    arg="$cmd"
    addr="$arg"
    ;;
  add|address)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    addr="$arg"
    ;;
  del)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    run_ip address del "$arg" dev "$if"
    ;;
  netmask)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    netmask="$arg"
    ;;
  broadcast)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    run_ip link set broadcast "$arg" dev "$if"
    ;;
  mtu)
    require_value "$cmd" ${1+"$1"} #${1+'^[1-9][0-9]*$'}
    arg="$1"; shift
    run_ip link set mtu "$arg" dev "$if"
    ;;
  txqueuelen)
    require_value "$cmd" ${1+"$1"} #${1+'^[1-9][0-9]*$'}
    arg="$1"; shift
    run_ip link set rxqueuelen "$arg" dev "$if"
    ;;
  hw)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    if [[ $cmd != ether ]]; then
      pdie "$cmd: $arg: Not supported"
    fi
    require_value "$cmd: $arg" ${1+"$1"}
    arg="$1"; shift
    run_ip link set address "$arg" dev "$if"
    ;;
  *)
    ## hostname?
    pdie "$cmd: Not supported"
    ;;
  esac
done

if [[ -n ${addr-} ]]; then
  if [[ -z ${netmask-} ]]; then
    run_ip address add "$addr" dev "$if"
  else
    run_ip address add "${addr%%/*}/$netmask" dev "$if"
  fi
fi

