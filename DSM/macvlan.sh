#!/bin/bash
cat >/etc/networkd-dispatcher/routable.d/macvlan-interfaces.sh<<EOF
#! /bin/bash
ip link add vdsm-shim link ens32 type macvlan mode bridge
EOF
chmod +x /etc/networkd-dispatcher/routable.d/macvlan-interfaces.sh

cat <<EOF >/etc/netplan/macvlan-interfaces.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    vdsm-shim:
      addresses:
        - 198.19.201.121/24
      routes:
        - to: 198.19.201.120/32
          via: 198.19.201.121
EOF
chmod 600 /etc/netplan/macvlan-interfaces.yaml