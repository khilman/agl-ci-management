#!/bin/bash

set -x

# Preclone the gerrit repos for speed (use with --reference=/opt/AGL/preclone)
mkdir -p /opt/AGL/preclone
cd /opt/AGL/preclone
repo init -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
repo sync
cd

#mirror sstate-cache into /opt/AGL/sstate-mirror
mkdir -p /opt/AGL/sstate-mirror
cd /opt/AGL/sstate-mirror
wget --mirror -np -nH --convert-links "https://download-new.automotivelinux.org/sstate-mirror/" -A siginfo -A tgz --cut-dirs=1
ls
ls *
cd

