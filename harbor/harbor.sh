#!/bin/bash
tar -zxvf harbor-offline-installer-v2.11.1.tgz
cd harbor/
cp harbor.yml.tmpl harbor.yml
#sed -i "s/hostname: .*/hostname: `ip route | grep -v default | egrep "eth|ens|enp"|awk '{print $NF}'`/"  harbor.yml
sed -i "s/hostname: .*/hostname: reg2.apen.ltd/"  harbor.yml
sed -i "s/https:/#https:/g"  harbor.yml
sed -i "s/port: 443/#port: 443/g"  harbor.yml
sed -i "s/certificate:/#certificate:/" harbor.yml
sed -i "s/private_key:/#private_key:/" harbor.yml
sed -i "s/  insecure: false/  insecure: true/g"   harbor.yml
bash install.sh

#docker compose down && rm -rf /data