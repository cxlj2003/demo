FROM registry.cn-hangzhou.aliyuncs.com/cxlj/openeuler:24.03-lts

RUN yum -y update && \
yum -y install dnf-plugins-core createrepo && \
rm -rf /etc/yum.repos.d/*

COPY local.repo /etc/yum.repos.d/local.repo
COPY start.sh /etc/start.sh

VOLUME [ "/opt/mirrors" ]

ENTRYPOINT ["/start.sh"]