#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt -y -qq install docker.io docker-compose
prj=
mkdir -p /opt/sh/${prj} && cd /opt/sh/${prj}
curl https://raw.githubusercontent.com/cxlj2003/demo/main/${prj}/compose.yml --connect-timeout 2 -o compose.yml 
curl https://gitee.com/cxlj2003/demo/raw/main/${prj}/compose.yml --connect-timeout 2 -o compose.yml 
docker-compose up -d