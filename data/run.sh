#!/bin/bash

#
# Run the OpenVPN server normally
#

OPENVPN=/data
OVPN_SERVER=10.1.1.0/24

#Exit immediately if a command exits with a non-zero status.
set -e

cd $OPENVPN


# set up iptables rules and routing
function setupIptablesAndRouting {
    iptables -t nat -C POSTROUTING -s $OVPN_SERVER -o $OVPN_NATDEVICE -j MASQUERADE 2>/dev/null || {
      iptables -t nat -A POSTROUTING -s $OVPN_SERVER -o $OVPN_NATDEVICE -j MASQUERADE
    }
    for i in "${OVPN_ROUTES[@]}"; do
        iptables -t nat -C POSTROUTING -s "$i" -o $OVPN_NATDEVICE -j MASQUERADE 2>/dev/null || {
          iptables -t nat -A POSTROUTING -s "$i" -o $OVPN_NATDEVICE -j MASQUERADE
        }
    done
}


mkdir -p /dev/net
if [ ! -c /dev/net/tun ]; then
    mknod /dev/net/tun c 10 200
fi


# When using --net=host, use this to specify nat device.
[ -z "$OVPN_NATDEVICE" ] && OVPN_NATDEVICE=eth0


# Setup NAT forwarding
setupIptablesAndRouting


#Set permission for openvpn to be quiet about permission warning
chmod 600 "$OPENVPN/server.key"


ip -6 route show default 2>/dev/null
if [ $? = 0 ]; then
    echo "Checking IPv6 Forwarding"
    if [ "$(</proc/sys/net/ipv6/conf/all/disable_ipv6)" != "0" ]; then
        echo "Sysctl error for disable_ipv6, please run docker with '--sysctl net.ipv6.conf.all.disable_ipv6=0'"
    fi

    if [ "$(</proc/sys/net/ipv6/conf/default/forwarding)" != "1" ]; then
        echo "Sysctl error for default forwarding, please run docker with '--sysctl net.ipv6.conf.default.forwarding=1'"
    fi

    if [ "$(</proc/sys/net/ipv6/conf/all/forwarding)" != "1" ]; then
        echo "Sysctl error for all forwarding, please run docker with '--sysctl net.ipv6.conf.all.forwarding=1'"
    fi
fi

openvpn --config /data/server.conf