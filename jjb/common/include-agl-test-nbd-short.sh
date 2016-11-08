# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Run SHORT CI test
################################################################################

# test currently only for porter, rest WIP
TESTRUN=false
echo "## ${MACHINE} ##"

case ${MACHINE} in
    porter-nogfx)

        TESTRUN=true
        TARGETMACHINE="porter"
        ;;
    porter)
        TESTRUN=true
        TARGETMACHINE="porter"
        ;;
    *)
        TESTRUN=false
        ;;
esac


if ${TESTRUN}; then

echo "#################################"
echo "TEST ENABLED for ${TARGETMACHINE}"
echo "#################################"

pushd tmp/deploy/images/${TARGETMACHINE}/

ROOTFSTOBOOT="none"
KERNELIMAGE="none"
NETBOOTIMAGE="none"
ls

function checkrootfs(){
    if test -f ./"$1" ; then
        eval ROOTFSTOBOOT="$1"
    fi
}


checkrootfs core-image-minimal-${TARGETMACHINE}.ext4
checkrootfs agl-image-ivi-${TARGETMACHINE}.ext4
checkrootfs agl-image-ivi-qa-${TARGETMACHINE}.ext4
checkrootfs agl-demo-platform-qa-${TARGETMACHINE}.ext4

if test x"none" = x"${ROOTFSTOBOOT}"; then
    echo "No rootfs to boot. Aborting"
    exit 1
fi



if test x"porter" = x"${TARGETMACHINE}"; then
KERNELIMAGE="zImage+dtb"
NETBOOTIMAGE="initramfs-netboot-image-porter.ext4.gz.u-boot"
fi

if test x"none" = x"${KERNELIMAGE}"; then
    echo "No kernelimage to boot. Aborting"
    exit 1
fi
if test x"none" = x"${NETBOOTIMAGE}"; then
    echo "No netbootimage to boot. Aborting"
    exit 1
fi

function maketmpfile() {
    DFILE=`mktemp -u -p ./ | sed -e "s#./##g"`
    eval cp -L \$$1 $DFILE
    export $1="$DFILE"
}

maketmpfile ROOTFSTOBOOT
maketmpfile KERNELIMAGE
maketmpfile NETBOOTIMAGE

set | grep ROOTFSTOBOOT
set | grep KERNELIMAGE
set | grep NETBOOTIMAGE

bash /opt/AGL/lava-agl/upload4lava.sh ${ROOTFSTOBOOT}
bash /opt/AGL/lava-agl/upload4lava.sh ${KERNELIMAGE}
bash /opt/AGL/lava-agl/upload4lava.sh ${NETBOOTIMAGE}

cat <<EOF > porterboot_nbd.yaml
actions:
    - command: deploy_linaro_kernel
      parameters:
          kernel: 'http://localhost/porter/upload/\${KERNELIMAGE}'
          nbdroot: 'http://localhost/porter/upload/\${ROOTFSTOBOOT}'
          ramdisk: 'http://localhost/porter/upload/\${NETBOOTIMAGE}'
          login_prompt: 'porter login:'
          username: 'root'
    - command: boot_linaro_image
      parameters:
          test_image_prompt: 'root@porter:~#'
    - command: lava_command_run
      parameters:
          commands:
            - "echo '#### START TEST ####'"
            - "echo '#### END TEST ####'"
          timeout: 3600
device_type: 'renesas-porter'
logging_level: INFO
job_name: '${JOB_NAME}'
timeout: 1800

EOF

cat /opt/AGL/lava-boot/lava-boot | sed -e 's#"~/.lava.yaml"#"/opt/AGL/lava-agl/lava.yaml"#' > ~/lava-boot
chmod a+x ~/lava-boot

logfile=$(mktemp)
~/lava-boot porter.automotivelinux.org -j ./porterboot_nbd.yaml -v ROOTFSTOBOOT="${ROOTFSTOBOOT}" -v KERNELIMAGE=${KERNELIMAGE} -v NETBOOTIMAGE=${NETBOOTIMAGE} 2>&1 | tee $logfile


popd


fi