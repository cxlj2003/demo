# https://docs.docker.com/engine/reference/builder/#understand-how-arg-and-from-interact
# https://docs.docker.com/engine/reference/builder/#automatic-platform-args-in-the-global-scope
FROM registry.cn-hangzhou.aliyuncs.com/cxlj/openeuler:22.03-lts as bootstrap

ARG TARGETARCH

ARG SP_VERSION

RUN echo "I'm building inlinux-23.12-sp${SP_VERSION} for arch ${TARGETARCH}"
RUN rm -rf /target && mkdir -p /target/etc/yum.repos.d && mkdir -p /etc/pki/rpm-gpg
COPY inlinux-23.12-lts-sp1.repo /target/etc/yum.repos.d/inlinux.repo
COPY RPM-GPG-KEY-InLinux /target/etc/pki/rpm-gpg/RPM-GPG-KEY-InLinux
COPY RPM-GPG-KEY-InLinux /etc/pki/rpm-gpg/RPM-GPG-KEY-InLinux

# see https://github.com/BretFisher/multi-platform-docker-build
# make the yum repo file with correct filename; eg: inlinux_x86_64.repo
RUN case ${TARGETARCH} in \
         "amd64")  ARCHNAME=x86_64  ;; \
         "arm64")  ARCHNAME=aarch64  ;; \
    esac && \
    mv /target/etc/yum.repos.d/inlinux.repo /target/etc/yum.repos.d/inlinux_${ARCHNAME}.repo

RUN yum --installroot=/target \
    --releasever=23.12LTS_SP1 \
    --setopt=tsflags=nodocs \
    install -y InLinux-release coreutils rpm yum bash procps tar

FROM scratch as runner
COPY --from=bootstrap /target /
RUN yum --releasever=23.12LTS_SP1 \
    --setopt=tsflags=nodocs \
    install -y InLinux-release coreutils rpm yum bash procps tar
RUN yum clean all && \
    rm -rf /var/cache/yum && \
    rm -rf /var/log/*
RUN  echo export LANG='en_US.UTF-8' >> /etc/profile && \
     echo export LC_ALL='en_US.UTF-8' >> /etc/profile && \
     source /etc/profile && \
     ln -snf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

FROM scratch
COPY --from=runner / /
CMD /bin/bash