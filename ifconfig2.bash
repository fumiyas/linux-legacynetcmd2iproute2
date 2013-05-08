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

if [[ $# == 0 ]]; then
  exec ip addr
  exit 1
fi

if="${1-}"; shift

if [[ $# == 0 ]]; then
  run ip addr show dev "$if"
  exit $?
fi

while [[ $# > 0 ]]; do
  arg="$1"; shift
  case "$arg" in
  up)
    run ip link set up dev "$if"
    ;;
  down)
    run ip link set down dev "$if"
    ;;
  arp|promisc)
    run ip link set "$arg" on dev "$if"
    ;;
  -arp|-promisc)
    run ip link set "${arg#-}" off dev "$if"
    ;;
  *.*.*.*|*::*)
    addr="$arg"
    run ip address add "$arg" dev "$if"
    ;;
  add|address)
    require_value "$arg" ${1+"$1"}
    arg="$1"; shift
    addr="$arg"
    run ip address add "$arg" dev "$if"
    ;;
  del)
    require_value "$arg" ${1+"$1"}
    arg="$1"; shift
    run ip address del "$arg" dev "$if"
    ;;
  netmask)
    require_value "$arg" ${1+"$1"}
    arg="$1"; shift
    run ip address add "${addr%%/*}/$arg" dev "$if"
    ;;
  broadcast)
    require_value "$arg" ${1+"$1"}
    arg="$1"; shift
    run ip link set broadcast "$arg" dev "$if"
    ;;
  mtu)
    require_value "$arg" ${1+"$1"} #${1+'^[1-9][0-9]*$'}
    arg="$1"; shift
    run ip link set mtu "$arg" dev "$if"
    ;;
  esac
done

