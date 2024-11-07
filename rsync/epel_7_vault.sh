#!/bin/bash
cat << 'EOF' > /opt/mirrors/include_epel1
+ aarch64/
+ aarch64/**
- *
EOF

cat << 'EOF' > /opt/mirrors/include_epel2
+ x86_64/
+ x86_64/**
- *
EOF

cat << 'EOF' > /opt/mirrors/include_epel3
+ source/
+ source/**
- *
EOF


/usr/bin/rsync -arztvP rsync://ftp-stud.hs-esslingen.de/fedora-archive/epel/7/ /opt/mirrors/epel/7/ --include-from=/opt/mirrors/include_epel1
/usr/bin/rsync -arztvP rsync://ftp-stud.hs-esslingen.de/fedora-archive/epel/7/ /opt/mirrors/epel/7/ --include-from=/opt/mirrors/include_epel2
/usr/bin/rsync -arztvP rsync://ftp-stud.hs-esslingen.de/fedora-archive/epel/7/ /opt/mirrors/epel/7/ --include-from=/opt/mirrors/include_epel3
