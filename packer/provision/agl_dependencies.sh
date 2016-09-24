#!/bin/bash

DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat \
                       libsdl1.2-dev xterm make xsltproc docbook-utils fop dblatex xmlto autoconf automake \
                       libtool libglib2.0-dev libarchive-dev python-git git python python-minimal repo mc \
                       tree rsync

mkdir -p /opt/AGL/preclone
cd /opt/AGL/preclone
repo init -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
repo sync
cd
