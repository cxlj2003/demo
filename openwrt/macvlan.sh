#!/bin/bash
cat <<EOF>/etc/networkd-dispatcher/routable.d/macvlan-interfaces.sh
#! /bin/bash
ip link add openwrt-shim link enp2s0 type macvlan mode bridge
EOF
chmod +x /etc/networkd-dispatcher/routable.d/macvlan-interfaces.sh

cat <<EOF >/etc/netplan/macvlan-interfaces.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    openwrt-shim:
      addresses:
        - 198.19.255.121/24
      routes:
        - to: 198.19.255.250/32
          via: 198.19.255.121
EOF
chmod 600 /etc/netplan/macvlan-interfaces.yaml