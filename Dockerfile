# syntax = docker/dockerfile:1.1-experimental

FROM openeuler/openeuler:24.03-lts-sp2

# install packages
RUN dnf makecache && \
    dnf install -y wget xz shadow dracut rsync git && \
    dnf clean all

COPY channels-lock.scm /
COPY entry-point.sh /
COPY guix_cache /
RUN chmod +x /entry-point.sh

# install guix
RUN pushd /tmp && \
    wget -O guix-binary-latest.x86_64-linux.tar.xz https://ci.z572.online/search/latest/archive?query=spec:guix-binary+status:success+system:x86_64-linux+guix-binary.tar.xz && \
    export GUIX_BINARY_FILE_NAME=guix-binary-latest.x86_64-linux.tar.xz && \
    wget -O guix-install.sh https://guix.gnu.org/install.sh && \
    chmod +x guix-install.sh && \
    yes '' | ./guix-install.sh && \
    popd

# import guix cache
#RUN --mount=type=secret,id=GUIX_CACHE_ACL_SIGNING_KEY_PUB  /entry-point.sh guix archive --authorize < /run/secrets/GUIX_CACHE_ACL_SIGNING_KEY_PUB 
#RUN cat /guix_cache | /entry-point.sh guix archive --import && rm -fr /guix_cache

# change guix source url
RUN sed -i "s@https://git.oerv.ac.cn/wangliu-iscas/guix-mirror.git@https://codeberg.org/guix/guix.git@" /channels-lock.scm

# guix work environment download and build guix 
#RUN --security=insecure sh -c '/entry-point.sh guix time-machine --substitute-urls='https://bordeaux.guix.gnu.org https://bordeaux-singapore-mirror.cbaines.net https://mirror.sjtu.edu.cn/guix' -C /channels-lock.scm -- describe --fallback'
RUN --security=insecure sh -c '/entry-point.sh guix time-machine --substitute-urls='https://bordeaux.guix.gnu.org https://bordeaux-singapore-mirror.cbaines.net https://mirror.sjtu.edu.cn/guix' -C /channels-lock.scm -- shell -D linux-libre --search-paths 

# recovery guix source url
RUN sed -i "s@https://codeberg.org/guix/guix.git@https://git.oerv.ac.cn/wangliu-iscas/guix-mirror.git@" /channels-lock.scm

# create result dir
RUN mkdir /srv/guix_result

# copy script
COPY guix-cross-build /usr/bin/guix-cross-build
RUN chmod +x /usr/bin/guix-cross-build

ENTRYPOINT ["/entry-point.sh"]
CMD ["sh"]