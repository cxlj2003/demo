#!/bin/bash
#----------------------------开启服务器telnet登陆---------------------------------------------#
#----------------------------开启服务器telnet登陆---------------------------------------------#
url=`cat /etc/yum.repos.d/kylin_aarch64.repo |egrep -v "#"|awk -F "/" '{print $3}'|uniq`;for i in $url;do sed -i "s#$i#172.20.41.67:27020/kylin#g" /etc/yum.repos.d/kylin_aarch64.repo;done
yum clean all && yum makecache
systemctl disable firewalld --now
setenforce 0

yum install xinetd telnet-server -y
cat <<EOF >/etc/xinetd.d/telnet
service telnet
{
    disable = no
    flags       = REUSE
    socket_type = stream       
    wait        = no
    user        = root
    server      = /usr/sbin/in.telnetd
    log_on_failure  += USERID
}
EOF
cat <<EOF >>/etc/securetty
pts/0
pts/1
pts/2
pts/3
pts/4
pts/5
pts/6
pts/7
pts/8
pts/9
pts/10
pts/11
pts/12
pts/13
pts/14
pts/15
EOF
cat <<EOF > /etc/pam.d/login
#%PAM-1.0
auth [user_unknown=ignore success=ok ignore=ignore default=bad] pam_securetty.so
auth       substack     system-auth
auth       include      postlogin
account    required     pam_nologin.so
account    include      system-auth
password   include      system-auth
# pam_selinux.so close should be the first session rule
session    required     pam_selinux.so close
session    required     pam_loginuid.so
session    optional     pam_console.so
# pam_selinux.so open should only be followed by sessions to be executed in the user context
session    required     pam_selinux.so open
session    required     pam_namespace.so
session    optional     pam_keyinit.so force revoke
session    include      system-auth
session    include      postlogin
-session   optional     pam_ck_connector.so
EOF
systemctl enable xinetd telnet.socket --now

#----------------------------Telnet至服务器上操作---------------------------------------------#
#----------------------------Telnet至服务器上操作---------------------------------------------#
yum -y install vim gcc gcc-c++ glibc make autoconf openssl openssl-devel pcre-devel pam-devel zlib-devel tcp_wrappers-devel tcp_wrappers libedit-devel perl-IPC-Cmd wget tar lrzsz nano
#yum -y install gcc pam-devel zlib-devel openssl-devel net-tools
cd /usr/local/src
wget 172.20.41.67:27020/soft/zlib-1.3.1.tar.gz
wget 172.20.41.67:27020/soft/openssl-3.3.1.tar.gz
wget 172.20.41.67:27020/soft/openssh-9.8p1.tar.gz

tar -zxvf zlib-1.3.1.tar.gz
tar -zxvf openssl-3.3.1.tar.gz
tar -zxvf openssh-9.8p1.tar.gz

cd /usr/local/src/zlib-1.3.1
./configure --prefix=/usr/local/zlib
make -j 4 && make test && make install

cd /usr/local/src/openssl-3.3.1
./config --prefix=/usr/local/openssl
make -j 4 && make install
mv /usr/bin/openssl /usr/bin/oldopenssl
ln -s /usr/local/openssl/bin/openssl /usr/bin/openssl
ln -s /usr/local/openssl/lib/libssl.so.3 /usr/lib64/libssl.so.3
ln -s /usr/local/openssl/lib/libcrypto.so.3 /usr/lib64/libcrypto.so.3

cat <<EOF >> /etc/ld.so.conf
/usr/local/zlib/lib
/usr/local/openssl/lib
EOF
ldconfig

yum -y remove openssh openssh-clients openssh-server 
rm -rf /etc/ssh/*
cd /usr/local/src/openssh-9.8p1
./configure --prefix=/usr \
--sysconfdir=/etc/ssh \
--with-pam \
--with-md5-passwords \
--with-ssl-dir=/usr/local/openssl \
--with-zlib=/usr/local/zlib

make -j 4 && make install

rm -f /etc/init.d/sshd
alias cp='cp'
cp -rf /usr/local/src/openssh-9.8p1/contrib/redhat/sshd.init /etc/init.d/sshd
cp -rf /usr/local/src/openssh-9.8p1/contrib/redhat/sshd.pam /etc/pam.d/sshd
alias cp='cp -i'
chkconfig --add sshd
chkconfig sshd on
systemctl start sshd
chmod 600 /etc/ssh/*_key
cat << EOF >>/etc/ssh/sshd_config
PermitRootLogin yes
PasswordAuthentication yes
EOF
systemctl restart sshd
rm -rf /usr/local/src/*

#systemctl disable telnet.socket xinetd --now
