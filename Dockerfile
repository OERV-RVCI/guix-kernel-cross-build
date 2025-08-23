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
    popd && \
    GUIX_PROFILE=/root/.config/guix/current; . "$GUIX_PROFILE/etc/profile" && \
    guix describe && \
    env LC_ALL=C.UTF-8 guix-daemon --build-users-group=guixbuild & 

# create result dir
RUN mkdir /srv/guix_result

# copy script
COPY guix-cross-build /usr/bin/guix-cross-build
RUN chmod +X /usr/bin/guix-cross-build
