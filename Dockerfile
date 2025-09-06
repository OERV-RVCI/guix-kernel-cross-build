# syntax = docker/dockerfile:1.1-experimental

FROM openeuler/openeuler:24.03-lts-sp2

# install packages
RUN dnf makecache && \
    dnf install -y wget xz shadow dracut rsync git && \
    dnf clean all

COPY channels-lock.scm /tmp
COPY entry-point.sh /
RUN chmod +x /entry-point.sh

# install guix
RUN pushd /tmp && \
    wget -O guix-binary-latest.x86_64-linux.tar.xz https://ci.z572.online/search/latest/archive?query=spec:guix-binary+status:success+system:x86_64-linux+guix-binary.tar.xz && \
    export GUIX_BINARY_FILE_NAME=guix-binary-latest.x86_64-linux.tar.xz && \
    wget -O guix-install.sh https://guix.gnu.org/install.sh && \
    chmod +x guix-install.sh && \
    yes '' | ./guix-install.sh && \
    popd

# guix work environment download
RUN --security=insecure sh -c '/entry-point.sh guix time-machine --substitute-urls='https://mirror.sjtu.edu.cn/guix https://bordeaux.guix.gnu.org https://bordeaux-singapore-mirror.cbaines.net' -C /tmp/channels-lock.scm -- describe'

# create result dir
RUN mkdir /srv/guix_result

# copy script
COPY guix-cross-build /usr/bin/guix-cross-build
RUN chmod +x /usr/bin/guix-cross-build

ENTRYPOINT ["/entry-point.sh"]
CMD ["sh"]