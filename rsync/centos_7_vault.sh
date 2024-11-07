#!/bin/bash
cat << 'EOF' > /opt/mirrors/include_vault1
+ 7*/
+ 7*/**
- *
EOF

cat << 'EOF' > /opt/mirrors/include_vault2
+ centos/
+ centos/7*/
+ centos/7*/**
- *
EOF

cat << 'EOF' > /opt/mirrors/include_vault3
+ altarch/
+ altarch/7*/
+ altarch/7*/**
- *
EOF

/usr/bin/rsync -arztvP rsync://mirrors.tuna.tsinghua.edu.cn/centos-vault/ /opt/mirrors/centos-vault/ --include-from=/opt/mirrors/include_vault1
/usr/bin/rsync -arztvP rsync://mirrors.tuna.tsinghua.edu.cn/centos-vault/ /opt/mirrors/centos-vault/ --include-from=/opt/mirrors/include_vault2
/usr/bin/rsync -arztvP rsync://mirrors.tuna.tsinghua.edu.cn/centos-vault/ /opt/mirrors/centos-vault/ --include-from=/opt/mirrors/include_vault3
