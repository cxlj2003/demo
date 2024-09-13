#!/bin/bash
cat << EOF >>/etc/rc.local
ip link add vdsm-shim link ens32 type macvlan  mode bridge
ip addr add 198.19.201.121/24 dev vdsm-shim
ip link set vdsm-shim up
ip route add 198.19.201.120/32 dev vdsm-shim
EOF
chmod +x /etc/rc.local
systemctl enable rc-local --now