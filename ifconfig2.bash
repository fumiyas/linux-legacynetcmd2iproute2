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
  echo "$@"
}

require_value()
{
  local name="$1"; shift

  if [[ $# -eq 0 ]]; then
    pdie "$name: requires value"
  fi

  local value="$1"; shift

  if [[ $# -gt 0 ]]; then
    if [[ $value =~ $1 ]]; then
      : OK
    else
      pdie "$name: invalid value: $value"
    fi
  fi
}

## ======================================================================

## FIXME: Ignore -a, -s and -v option

if [[ $# == 0 ]]; then
  exec ip addr
  exit 1
fi

if="${1-}"; shift

if [[ $# == 0 ]]; then
  run ip addr show dev "$if"
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

while [[ $# > 0 ]]; do
  cmd="$1"; shift
  case "$cmd" in
  up)
    run ip ${af:+-f "$af"} link set up dev "$if"
    ;;
  down)
    run ip ${af:+-f "$af"} link set down dev "$if"
    ;;
  arp|dynamic|multicast|promisc|trailers|txqueuelen)
    run ip ${af:+-f "$af"} link set "$cmd" on dev "$if"
    ;;
  -arp|-dynamic|-multicast|-promisc|-trailers)
    run ip ${af:+-f "$af"} link set "${cmd#-}" off dev "$if"
    ;;
  allmulti)
    run ip ${af:+-f "$af"} link set allmulticast on dev "$if"
    ;;
  -allmulti)
    run ip ${af:+-f "$af"} link set allmulticast off dev "$if"
    ;;
  pointopoint|-pointopoint|dstaddr|tunnel|outfill|keepalive|metric)
    ## FIXME: ip route?
    pdie "$cmd: Not supported yet"
    ;;
  mem_start|io_addr|irq|media)
    ## FIXME: ethtool
    pdie "$cmd: Not supported yet"
    ;;
  add|address)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    run ip ${af:+-f "$af"} address add "$arg" dev "$if"
    addr="$arg"
    ;;
  del)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    run ip ${af:+-f "$af"} address del "$arg" dev "$if"
    ;;
  netmask)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    run ip ${af:+-f "$af"} address add "${addr%%/*}/$arg" dev "$if"
    ;;
  broadcast)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    run ip ${af:+-f "$af"} link set broadcast "$arg" dev "$if"
    ;;
  mtu)
    require_value "$cmd" ${1+"$1"} #${1+'^[1-9][0-9]*$'}
    arg="$1"; shift
    run ip ${af:+-f "$af"} link set mtu "$arg" dev "$if"
    ;;
  hw)
    require_value "$cmd" ${1+"$1"}
    arg="$1"; shift
    if [[ $cmd != ether ]]; then
      pdie "$cmd: $arg: Not supported"
    fi
    require_value "$cmd: $arg" ${1+"$1"}
    arg="$1"; shift
    run ip ${af:+-f "$af"} link set address "$arg" dev "$if"
    ;;
  *)
    ## IPv4, IPv6 address or hostname
    arg="$cmd"
    run ip ${af:+-f "$af"} address add "$arg" dev "$if"
    addr="$arg"
    ;;
  esac
done

