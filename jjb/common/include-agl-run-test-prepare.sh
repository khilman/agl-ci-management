# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Run SHORT CI test
################################################################################
#set -x

#ls -alh
#pwd
#set

cd $REPODIR

ls -alhR meta-agl/templates/machine/${MACHINE}

#### Find out if machine can be tested.
#### We keep a stamp file in meta-agl/templates/machine/$MACHINE/test
if [ ! -d meta-agl/templates/machine/${MACHINE}/test ]; then
  echo "No HW test templates for ${MACHINE} configured."
  echo "Add meta-agl/templates/machine/${MACHINE}/test/ and its contents to enable"
  exit 0
fi

if [ ! -f meta-agl/templates/machine/${MACHINE}/test/hwtest.enable ] ; then 
  echo "No HW test for ${MACHINE} configured."
  echo "Add meta-agl/templates/machine/${MACHINE}/test/hwtest.enable to enable"
  exit 0
fi

if [ ! -f meta-agl/templates/machine/${MACHINE}/test/hwtest.short.enable ] ; then
  echo "No short HW test for ${MACHINE} configured."
  echo "Add meta-agl/templates/machine/${MACHINE}/test/hwtest.enable.short to enable"
else
  eval export ENVFILE=meta-agl/templates/machine/${MACHINE}/test/hwtest.short.environment
  eval export TESTJOBFILE=meta-agl/templates/machine/${MACHINE}/test/testjob_short.yaml
fi

if [ ! -f $ENVFILE ] ; then
  echo "No short HW test environment file available for ${MACHINE}."
  echo "Add ${ENVFILE} to enable."
  exit 1
fi

if [ ! -e $TESTJOBFILE ] ; then
  echo "No short HW test environment file available for ${MACHINE}."
  echo "Add ${TESTJOBFILE} to enable."
  exit 1
fi

# some defaults
export DEVICE_TYPE=raspberrypi3-uboot
export DEVICE_NAME=raspberrypi3
export DEVICE_DTB=uImage-bcm2710-rpi-3-b.dtb
export DEVICE_KERNEL=uImage
export DEVICE_INITRAMFS=initramfs-netboot-image-raspberrypi3.ext4
export DEVICE_NBDROOT=agl-demo-platform-raspberrypi3.ext4
export DEVICE_NBDROOT_COMPRESSION=none
export DEVICE_BOOT_METHOD=u-boot
export DEVICE_BOOT_TYPE=bootm
export DEVICE_URL_PREFIX='https://download.automotivelinux.org/AGL/upload/ci/'


# import device defaults. Format 'a=b'
for i in DEVICE_TYPE DEVICE_NAME DEVICE_DTB DEVICE_KERNEL DEVICE_INITRAMFS DEVICE_NBDROOT DEVICE_NBDROOT_COMPRESSION DEVICE_BOOT_METHOD DEVICE_BOOT_TYPE; do
    if grep -q $i $ENVFILE ; then
        X=$(grep $i $ENVFILE | sed -e "s#${i}=##g" -e "s#;.*##g")
        eval export ${i}=${X}
    fi
done

echo "Resulting values:"
set | grep DEVICE_


# echo NEXT is rsync
#exit 0

