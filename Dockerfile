FROM openeuler/openeuler:24.03-lts-sp2

# install packages
RUN dnf makecache && \
    dnf install -y wget xz shadow dracut rsync git && \
    dnf clean all

COPY channels-lock.scm /

# install guix
RUN pushd /tmp && \
    wget -O guix-install.sh https://guix.gnu.org/install.sh && \
    chmod +x guix-install.sh && \
    yes '' | ./guix-install.sh && \
    popd && \
    guix time-machine --substitute-urls=https://mirror.sjtu.edu.cn/guix -C channels-lock.scm -- describe

# create result dir
RUN mkdir /srv/guix_result

# copy script
COPY guix-cross-build /usr/bin/guix-cross-build
COPY entry-point.sh /
RUN chmod +x /usr/bin/guix-cross-build
RUN chmod +x /entry-point.sh

ENTRYPOINT ["/entry-point.sh"]
CMD ["sh"]