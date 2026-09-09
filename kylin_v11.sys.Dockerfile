# Build a minimal Kylin Linux Advanced Server V11 (2503) rootfs.

ARG BASE_IMAGE=openeuler/openeuler:24.03-lts-sp2
FROM ${BASE_IMAGE} AS bootstrap

ARG TARGETARCH

RUN echo "Building Kylin Linux Advanced Server V11 (2503) for ${TARGETARCH}"
RUN rm -rf /target && \
    mkdir -p /target/etc/yum.repos.d /target/etc/pki/rpm-gpg /etc/pki/rpm-gpg

COPY kylin-V11SP3.repo /target/etc/yum.repos.d/kylin.repo
COPY RPM-GPG-KEY-kylin /target/etc/pki/rpm-gpg/RPM-GPG-KEY-kylin
COPY RPM-GPG-KEY-kylin /etc/pki/rpm-gpg/RPM-GPG-KEY-kylin

RUN case ${TARGETARCH} in \
         "amd64") ARCHNAME=x86_64 ;; \
         "arm64") ARCHNAME=aarch64 ;; \
         *) echo "Unsupported target architecture: ${TARGETARCH}" >&2; exit 1 ;; \
    esac && \
    mv /target/etc/yum.repos.d/kylin.repo /target/etc/yum.repos.d/kylin_${ARCHNAME}.repo

RUN dnf --installroot=/target \
    --releasever=11 \
    --setopt=tsflags=nodocs \
    --setopt=install_weak_deps=False \
    install -y kylin-release coreutils rpm dnf bash procps-ng tar

FROM scratch AS runner
COPY --from=bootstrap /target /

RUN dnf --releasever=11 \
    --setopt=tsflags=nodocs \
    --setopt=install_weak_deps=False \
    install -y kylin-release coreutils rpm dnf bash procps-ng tar

RUN ln -s dnf /usr/bin/yum

RUN dnf clean all && \
    rm -rf /var/cache/dnf /var/cache/yum /var/log/*

FROM scratch
COPY --from=runner / /
CMD ["/bin/bash"]
