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
Host 10.30.96.* 10.30.97.*
  StrictHostKeyChecking no
  UserKnownHostsFile /dev/null
EOSSH

cat <<EOKNOWN >  /etc/ssh/ssh_known_hosts
[gerrit-new.automotivelinux.org]:39418,[198.145.29.87]:39418 ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDLlq8OD28YY+RRU2rcBxV0agWQsgD+ywpObFtjO0uxhxWWz0wtJdu0NDGpFH9AFE64AeBx7NFIYjuXWtWQIwSHgXyx0hejL9257YWsQ8dPsnEsUT6PehE68MA1eg4S5lT/9NjVeAhWgPBVNdtcP0oex2Pf/qr6aKZVUq9msemzZHAVmBKKHTFQTePW50JObQyXHQTSB572OV/haVob+3k6EQrtFdD3dg3/KDvgtuIjmW+Bp7amT7ZwtL0ekCWZqM6V8M1tqsy0WaJJhdjDf/Tc4d+wGNXFnU5niVDbBdlFVqQSVgGuSNIbu/y9ZRF14dOe97YMykxCJk7fDnsjdnmR
EOKNOWN

# vim: sw=2 ts=2 sts=2 et :
