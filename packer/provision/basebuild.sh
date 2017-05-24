#!/bin/bash -x
# vim: set tw=4 sw=4 sts=4 et :

# Presently nothing to do

set -x

cat <<EOFSTAB >> /etc/fstab

# tmp should be tmpfs so gcc tmpfiles do not hit the disk
none /tmp tmpfs defaults 0 0

EOFSTAB

# The following installs hashicorp's packer binary which is required  for
# ci-management-{verify,merge}-packer jobs
mkdir /tmp/packer
cd /tmp/packer
wget https://releases.hashicorp.com/packer/1.0.0/packer_1.0.0_linux_amd64.zip
unzip packer_1.0.0_linux_amd64.zip -d /usr/local/bin/
# rename packer to avoid conflict with binary in cracklib
mv /usr/local/bin/packer /usr/local/bin/packer.io
