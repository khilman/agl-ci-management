#!/bin/bash
# @License EPL-1.0 <http://spdx.org/licenses/EPL-1.0>
##############################################################################
# Copyright (c) 2016 The Linux Foundation and others.
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v1.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v10.html
##############################################################################

case "$(facter operatingsystem)" in
  Ubuntu)
    apt-get update
    ;;
  *)
    # Do nothing on other distros for now
    ;;
esac

IPADDR=$(facter ipaddress)
HOSTNAME=$(facter hostname)
FQDN=$(facter fqdn)

echo "${IPADDR} ${HOSTNAME} ${FQDN}" >> /etc/hosts

#Increase limits
cat <<EOF > /etc/security/limits.d/jenkins.conf
jenkins         soft    nofile          16000
jenkins         hard    nofile          16000
EOF

cat <<EOSSH >> /etc/ssh/ssh_config
Host *
  ServerAliveInterval 60

# we don't want to do SSH host key checking on spin-up systems
Host 10.30.72.*
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

Host vex-yul-agl-download.ci.codeaurora.org
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null

EOSSH

cat <<EOKNOWN >  /etc/ssh/ssh_known_hosts
[gerrit.automotivelinux.org]:29418,[198.145.29.87]:29418 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAAAgQC7mx+OxVdwr6s5M/JJn5DxxVu9n7dfIZrB+mS88m51oJmHCWDBGEncpUskrzAwI5uXYTeG4FamcxtrHumVL3oZ6F4m93DG486/LM/4ff8qbEjYNoYYqY004wW2kbg1ivZ/DWmIyAyw0JCOv+Ia39krT5Zv6LI68skimCE/6pRbsw==
vex-yul-agl-download.ci,10.30.72.8 ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBNaxEOWbShvqQWqS17c123Ct8tBLBVVOPTNYpZSmwd1UKVQi9cF0QMOU7Rc479bHwzuLscvmohpGh2kP0CmHvAo=
EOKNOWN


cat <<EOFHOSTS >> /etc/hosts

# workaround for download-new
199.19.213.77 download-new.automotivelinux.org

EOFHOSTS

# vim: sw=2 ts=2 sts=2 et :
