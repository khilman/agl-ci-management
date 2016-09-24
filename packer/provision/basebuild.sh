#!/bin/bash -x
# vim: set tw=4 sw=4 sts=4 et :

# Presently nothing to do

cat <<EOFSTAB >> /etc/fstab

# tmp should be tmpfs so gcc tmpfiles do not hit the disk
none /tmp tmpfs defaults 0 0

EOFSTAB
