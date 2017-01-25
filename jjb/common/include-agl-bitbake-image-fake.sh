# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## bitbake the image
################################################################################

# finally, build the agl-demo-platform (we retry to catch the tar-native bug)
#( ( bitbake $TARGETIMAGE ) || ( echo '## Failed once, retry ..  ##' ; sync ; sleep 2 ;  bitbake $TARGETIMAGE ) ) || ( echo '## Failed again, bail out ...' ; exit 1 ) 

if [ x"${MACHINE}" = x"raspberrypi3" ] ; then
export DEVICE_TYPE=raspberrypi3-uboot
export DEVICE_NAME=raspberrypi3
export DEVICE_DTB=uImage-bcm2710-rpi-3-b.dtb
export DEVICE_KERNEL=uImage
export DEVICE_INITRAMFS=initramfs-netboot-image-raspberrypi3.ext4.gz.u-boot
export DEVICE_NBDROOT=agl-demo-platform-raspberrypi3.ext4
else
    echo "This fake build script is for raspberrypi3 only."
    exit 1
fi


mkdir -p tmp/deploy/images/${MACHINE}/

pushd tmp/deploy/images/${MACHINE}/

for i in DEVICE_DTB DEVICE_KERNEL DEVICE_INITRAMFS DEVICE_NBDROOT ; do
    eval curl -o "$(echo "$"${i})" "http://download-new.automotivelinux.org/AGL/snapshots/master/2017-01-08-b241/${MACHINE}/deploy/images/${MACHINE}/$(echo "$"${i})"
    ls -alh 
done

ls -alh

popd

du -hs tmp/deploy/*
