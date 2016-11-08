# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Build vmdk file for qemux86*
################################################################################

if test x"qemux86" == x"$MACHINE" -o x"qemux86-64" == x"$MACHINE" ; then
 echo 'IMAGE_FSTYPES += "vmdk"' >> conf/local.conf
fi
