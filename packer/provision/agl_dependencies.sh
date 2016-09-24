#!/bin/bash

DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat \
                       libsdl1.2-dev xterm make xsltproc docbook-utils fop dblatex xmlto autoconf automake \
                       libtool libglib2.0-dev libarchive-dev python-git git python python-minimal repo mc \
                       tree rsync

# we have a build blocker wrt useradd - I assume it is caused by /bin/sh being dash
# systemd: Performing useradd with
echo "dash dash/sh boolean false" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

# Preclone the gerrit repos for speed (use with --reference=/opt/AGL/preclone)
mkdir -p /opt/AGL/preclone
cd /opt/AGL/preclone
repo init -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
repo sync
cd
