# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Main
################################################################################

# source the env
source meta-agl/scripts/aglsetup.sh -m ${MACHINE} -b output ${TARGETFEATURES}

# link the shared downloads and sstate-cache
ln -sf ../../downloads
ln -sf ../../sstate-cache

echo "" >> conf/local.conf
echo "### ADDED BY AUTOBUILDER ###" >> conf/local.conf
echo "" >> conf/local.conf
