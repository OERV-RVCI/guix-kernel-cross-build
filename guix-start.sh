#!/bin/bash

set -x

GUIX_PROFILE=/root/.config/guix/current; . "$GUIX_PROFILE/etc/profile" && \
guix describe && \
env LC_ALL=C.UTF-8 guix-daemon --build-users-group=guixbuild &