#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt -y  install docker.io docker-compose
mkdir -p /opt/sh/seafile && cd /opt/sh/seafile
curl --connect-timeout 2 -o compose.yml https://raw.githubusercontent.com/cxlj2003/demo/main/seafile/compose.yml
curl --connect-timeout 2 -o compose.yml https://gitee.com/cxlj2003/demo/raw/main/seafile/compose.yml
docker-compose up -d