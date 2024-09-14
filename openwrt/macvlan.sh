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


####openwrt 
####immortalwrt https://github.com/immortalwrt/immortalwrt
####lean 
####istoreos 
####kwrt 10.0.0.1 密码root  https://github.com/kiddin9/Kwrt https://openwrt.ai/docker%E7%89%88openwrt%E6%97%81%E8%B7%AF%E7%94%B1%E5%AE%89%E8%A3%85%E8%AE%BE%E7%BD%AE%E6%95%99%E7%A8%8B/