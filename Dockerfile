FROM openeuler/openeuler:24.03-lts-sp2

# install packages
RUN dnf makecache && \
    dnf install -y wget xz shadow dracut rsync git && \
    dnf clean all

# install guix
RUN pushd /tmp && \
    wget -O guix-install.sh https://guix.gnu.org/install.sh && \
    chmod +x guix-install.sh && \
    yes '' | ./guix-install.sh && \
    popd

# create result dir
RUN mkdir /srv/guix_result

# copy script
COPY guix-cross-build /usr/bin/guix-cross-build
COPY guix-start.sh /usr/bin/guix-start.sh
RUN chmod +x /usr/bin/guix-cross-build
RUN chmod +x /usr/bin/guix-start.sh

ENTRYPOINT /usr/bin/guix-start.sh && /bin/bash