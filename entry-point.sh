#!/bin/sh
#
#	MetaCall Guix by Parra Studios
#	Docker image for using Guix in a CI/CD environment.
#
#	Copyright (C) 2016 - 2024 Vicente Eduardo Ferrer Garcia <vic798@gmail.com>
#
#	Licensed under the Apache License, Version 2.0 (the "License");
#	you may not use this file except in compliance with the License.
#	You may obtain a copy of the License at
#
#		http://www.apache.org/licenses/LICENSE-2.0
#
#	Unless required by applicable law or agreed to in writing, software
#	distributed under the License is distributed on an "AS IS" BASIS,
#	WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#	See the License for the specific language governing permissions and
#	limitations under the License.
#

# 设置 SSL 证书环境变量
if [ -d /etc/pki/tls/certs ]; then
    export SSL_CERT_DIR=/etc/pki/tls/certs
    export SSL_CERT_FILE=/etc/pki/tls/certs/ca-bundle.crt
    export GIT_SSL_CAINFO=/etc/pki/tls/certs/ca-bundle.crt
elif [ -d /etc/ssl/certs ]; then
    export SSL_CERT_DIR=/etc/ssl/certs
    export SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt
    export GIT_SSL_CAINFO=/etc/ssl/certs/ca-certificates.crt
fi

# Load profile enviroment variables
source $GUIX_PROFILE/etc/profile

# Run guix daemon
/root/.config/guix/current/bin/guix-daemon --build-users-group=guixbuild &
GUIX_DAEMON=$!

# Execute commands
"$@"
GUIX_RESULT=$?

# Kill guix daemon
kill -9 $GUIX_DAEMON

# Exit with guix status
exit $GUIX_RESULT