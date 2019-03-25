#!/usr/bin/env bash

unset CDPATH;

set -ex

DEBIAN_FRONTEND=noninteractive

apt-get update

# install lxd, curl, jq
apt-get install -y \
    curl \
    jq \
    lxd \
    lxd-client

# configure lxd, accept all the defaults
lxd init --auto

# add the user to the lxd group
usermod -a -G lxd vagrant

# setup the lxd daemon for HTTPS API communication with password
lxc config set core.https_address "[::]:8443"
lxc config set core.trust_password "password"

# setup client keys
KEYDIR=/vagrant
openssl req -newkey rsa:2048 -nodes -keyout ${KEYDIR}/lxd.key -out ${KEYDIR}/lxd.csr -batch
openssl x509 -signkey ${KEYDIR}/lxd.key -in ${KEYDIR}/lxd.csr -req -days 365 -out ${KEYDIR}/lxd.crt

# check that the certificate is not currently trusted
[ "$(curl -s -k --cert ${KEYDIR}/lxd.crt --key ${KEYDIR}/lxd.key https://127.0.0.1:8443/1.0 | jq .metadata.auth)" == "\"untrusted\"" ]

# make our certificate trusted
curl -s -k --cert ${KEYDIR}/lxd.crt --key ${KEYDIR}/lxd.key https://127.0.0.1:8443/1.0/certificates -X POST -d '{"type": "client", "password": "password"}' | jq .

# check that the certificate is now trusted
[ "$(curl -s -k --cert ${KEYDIR}/lxd.crt --key ${KEYDIR}/lxd.key https://127.0.0.1:8443/1.0 | jq .metadata.auth)" == "\"trusted\"" ]

