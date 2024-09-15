#!/bin/bash
###MACVLAN模式网络创建脚本
NIC=`ip route | egrep -v "br|docker|default|static" | egrep "eth|ens|enp"|awk '{print $3}'` 
MACVLANNIC=`docker network ls | grep macvlan-$NIC |wc -l`
#创建docker网络
if [ $MACVLANNIC -ne 1 ];then
docker network create -d macvlan --subnet=198.19.201.0/24 --gateway=198.19.201.254 -o parent=$NIC macvlan-$NIC
fi
#创建macvlan路由接口
cat <<EOF>/etc/networkd-dispatcher/routable.d/macvlan-$NIC.sh
#! /bin/bash
ip link add macvlan-$NIC link $NIC type macvlan mode bridge
EOF
chmod +x /etc/networkd-dispatcher/routable.d/macvlan-$NIC.sh && bash /etc/networkd-dispatcher/routable.d/macvlan-$NIC.sh
#创建间macvlan路由
cat <<EOF >/etc/netplan/macvlan-$NIC.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    macvlan-$NIC:
      addresses:
        - 198.19.201.253/32
      routes:
        - to: 198.19.201.252/32
          via: 198.19.201.253
        - to: 198.19.201.251/32
          via: 198.19.201.253		  
EOF
chmod 600 /etc/netplan/macvlan-$NIC.yaml
netplan apply

####openwrt 
####immortalwrt https://github.com/immortalwrt/immortalwrt https://downloads.immortalwrt.org/ 精简系统
####lean 
####istoreos 
####kwrt 10.0.0.1 密码root  https://github.com/kiddin9/Kwrt https://openwrt.ai/docker%E7%89%88openwrt%E6%97%81%E8%B7%AF%E7%94%B1%E5%AE%89%E8%A3%85%E8%AE%BE%E7%BD%AE%E6%95%99%E7%A8%8B/ 
####registry.cn-hangzhou.aliyuncs.com/cxlj/kwrt:08.28.2024-x86-64 
#ip addr add 198.19.201.252/24 dev br-lan