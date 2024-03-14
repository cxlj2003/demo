#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt -y  install docker.io docker-compose
mkdir -p /opt/sh/embyserver && cd /opt/sh/embyserver
if [ -!f /opt/sh/embyserver/compose.yml ]; then
	curl --connect-timeout 2 -o compose.yml https://raw.githubusercontent.com/cxlj2003/demo/main/embyserver/compose.yml
	if [ -!f /opt/sh/embyserver/compose.yml ]; then
		curl --connect-timeout 2 -o compose.yml https://gitee.com/cxlj2003/demo/raw/main/embyserver/compose.yml
	fi
fi
docker-compose up -d