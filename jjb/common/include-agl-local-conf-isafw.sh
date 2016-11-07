# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Main
################################################################################

# meta-security-isafw
echo "BBLAYERS += \" $(pwd)/../meta-security-isafw \" " >> conf/bblayers.conf
echo "INHERIT += \"isafw\" " >> conf/local.conf
