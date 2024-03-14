#!/bin/bash
#1apt静默安装
cat << EOF >/etc/profile.d/apt.sh
export DEBIAN_FRONTEND=noninteractive
EOF
source /etc/profile
echo $DEBIAN_FRONTEND
#2ssh运行Root登录
echo PermitRootLogin yes >> /etc/ssh/sshd_config
systemctl restart sshd