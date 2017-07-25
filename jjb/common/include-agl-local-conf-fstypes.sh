# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Change FSTYPES to sane values
################################################################################

# "old"
echo 'IMAGE_FSTYPES_remove = "ext4"' >> conf/local.conf
echo 'IMAGE_FSTYPES_remove = "ext3"' >> conf/local.conf
echo 'IMAGE_FSTYPES_remove = "tar.bz2"' >> conf/local.conf
echo 'IMAGE_FSTYPES_remove = "tar.gz"' >> conf/local.conf
echo 'IMAGE_FSTYPES_remove = "iso"' >> conf/local.conf
echo 'IMAGE_FSTYPES_remove = "hddimg"' >> conf/local.conf
echo 'IMAGE_FSTYPES += "tar.xz ext4.xz "' >> conf/local.conf

# "new"
echo 'AGL_DEFAULT_IMAGE_FSTYPES := "ext4.xz tar.xz"' >> conf/local.conf
