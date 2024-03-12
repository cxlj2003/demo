#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
apt -y  install docker.io docker-compose
mkdir -p /opt/sh/embyserver
cd /opt/sh/embyserver
curl -o compose.yml https://raw.githubusercontent.com/cxlj2003/demo/main/embyserver/compose.yml?token=GHSAT0AAAAAACPLGX4MCGX35WBUBK2QBHEGZPP6KYA
docker-compose up -d