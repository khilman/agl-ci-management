# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Main
################################################################################

# archive sources within  tmp/deploy/
echo 'INHERIT += "archiver"' >> conf/local.conf
echo 'ARCHIVER_MODE[src] = "original"' >> conf/local.conf
