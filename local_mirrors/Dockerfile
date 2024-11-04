FROM registry.cn-hangzhou.aliyuncs.com/cxlj/openeuler:24.03-lts
ENV TZ=Asia/Shanghai
RUN yum -y update && \
yum -y install dnf-plugins-core createrepo cronie && \
rm -rf /etc/yum.repos.d/* && \
yum clean all && rm -rf /var/cache/dnf/*

COPY local.repo /etc/yum.repos.d/local.repo
COPY start.sh /start.sh

VOLUME [ "/opt/mirrors" ]

ENTRYPOINT [ "/start.sh"  ]