# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Add isafw report and enable
################################################################################

# meta-security-isafw
echo "BBLAYERS += \" $(pwd)/../meta-security-isafw \" " >> conf/bblayers.conf
echo "INHERIT += \"isafw\" " >> conf/local.conf
