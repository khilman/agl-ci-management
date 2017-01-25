# (c) 2017 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Add archiver
################################################################################

# only morty and newer support the cve-check, so check for master branch

if [ x"master" = x"$GERRIT_BRANCH" ] ; then

# archive sources within  tmp/deploy/
echo '' >> conf/local.conf
echo 'INHERIT += "cve-check"' >> conf/local.conf

fi