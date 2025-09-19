FROM registry.cn-hangzhou.aliyuncs.com/cxlj/kylin:v10-sp3
ENV TZ=Asia/Shanghai
RUN yum -y update && \
yum -y install dnf-plugins-core createrepo cronie findutils vim && \
rm -rf /etc/yum.repos.d/* && \
yum clean all && rm -rf /var/cache/dnf/*

COPY local.repo /etc/yum.repos.d/local.repo
COPY start.sh /start.sh

VOLUME [ "/opt/mirrors" ]

ENTRYPOINT [ "/start.sh"  ]