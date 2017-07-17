# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Run SHORT CI test
################################################################################


set -x

echo "## ${MACHINE} ##"
cd $REPODIR

cat <<EOF > testjob.yaml
# Your first LAVA JOB definition for a $MACHINE board
device_type: @REPLACE_DEVICE_TYPE@
job_name: AGL-short-smoke

timeouts:
  job:
    minutes: 30
  action:
    minutes: 15
  connection:
    minutes: 5
priority: medium
visibility: public
EOF

if [ ${DEVICE_BOOT_METHOD} = "u-boot" ]; then
cat <<EOF >> testjob.yaml

protocols:
  lava-xnbd:
    port: auto

# ACTION_BLOCK
actions:
- deploy:
    timeout:
      minutes: 10
    to: nbd
    dtb:
      url: '@REPLACE_URL_PREFIX@/@REPLACE_DTB@'
    kernel:
      url: '@REPLACE_URL_PREFIX@/@REPLACE_KERNEL@'
    initrd:
      url: '@REPLACE_URL_PREFIX@/@REPLACE_INITRAMFS@'
      allow_modify: false
    nbdroot:
      url: '@REPLACE_URL_PREFIX@/@REPLACE_NBDROOT@'
      compression: @REPLACE_NBDROOT_COMPRESSION@
    os: debian
    failure_retry: 2

# BOOT_BLOCK
- boot:
    method: @REPLACE_BOOT_METHOD@
    commands: nbd
    type: @REPLACE_BOOT_TYPE@
    prompts: ["root@@REPLACE_MACHINE@:~"]
    auto_login:
      login_prompt: "login:"
      username: root

EOF
fi

if [ ${DEVICE_BOOT_METHOD} = "qemu" ]; then
cat <<EOF >>testjob.yaml
context:
  no_kvm: true
  arch: @REPLACE_DEVICE_ARCH@
  extra_options: [@REPLACE_QEMU_ARGS@]
 
actions:
- deploy:
    timeout:
      minutes: 3
    to: tmpfs
    os: oe
    images:
        kernel:
          image_arg: '-kernel {kernel} -append @REPLACE_KERNEL_CMDLINE@'
          url: '@REPLACE_URL_PREFIX@/@REPLACE_KERNEL@'
        ramdisk:
          image_arg: '-drive format=raw,file={ramdisk}'
          url: '@REPLACE_URL_PREFIX@/@REPLACE_INITRAMFS@'
          compression: @REPLACE_INITRAMFS_COMPRESSION@

- boot:
    method: @REPLACE_BOOT_METHOD@
    media: tmpfs
    prompts: ["root@@REPLACE_MACHINE@:~"]
    auto_login:
      login_prompt: "login:"
      username: root

EOF
fi

CHID=${GERRIT_CHANGE_NUMBER}/${GERRIT_PATCHSET_NUMBER}/${MACHINE}
# REPLACE_DEVICE_TYPE
sed -i -e "s#@REPLACE_DEVICE_ARCH@#${DEVICE_ARCH}#g" testjob.yaml
sed -i -e "s#@REPLACE_DEVICE_TYPE@#${DEVICE_TYPE}#g" testjob.yaml
sed -i -e "s#@REPLACE_DTB@#${CHID}/${DEVICE_DTB}#g" testjob.yaml
sed -i -e "s#@REPLACE_KERNEL@#${CHID}/${DEVICE_KERNEL}#g" testjob.yaml
sed -i -e "s#@REPLACE_INITRAMFS@#${CHID}/${DEVICE_INITRAMFS}#g" testjob.yaml
sed -i -e "s#@REPLACE_INITRAMFS_COMPRESSION@#${DEVICE_INITRAMFS_COMPRESSION}#g" testjob.yaml
sed -i -e "s#@REPLACE_NBDROOT@#${CHID}/${DEVICE_NBDROOT}#g" testjob.yaml
sed -i -e "s#@REPLACE_NBDROOT_COMPRESSION@#${DEVICE_NBDROOT_COMPRESSION}#g" testjob.yaml
sed -i -e "s#@REPLACE_BOOT_METHOD@#${DEVICE_BOOT_METHOD}#g" testjob.yaml
sed -i -e "s#@REPLACE_BOOT_TYPE@#${DEVICE_BOOT_TYPE}#g" testjob.yaml
sed -i -e "s#@REPLACE_MACHINE@#${DEVICE_NAME}#g" testjob.yaml
sed -i -e "s#@REPLACE_URL_PREFIX@#${DEVICE_URL_PREFIX}#g" testjob.yaml
sed -i -e "s#@REPLACE_QEMU_ARGS@#${DEVICE_QEMU_ARGS}#g" testjob.yaml
sed -i -e "s#@REPLACE_KERNEL_CMDLINE@#${DEVICE_KERNEL_CMDLINE}#g" testjob.yaml

cat testjob.yaml

lava-tool submit-job --block https://agl-jenkins-user@lava.automotivelinux.org testjob.yaml | tee .myjob

MYJOB=`cat .myjob | grep "submitted as job" | sed -e "s#submitted as job id: ##g"`

echo "#### JOBID: $MYJOB #####"

( lava-tool job-status https://agl-jenkins-user@lava.automotivelinux.org $MYJOB | tee .status ) || true
STATUS=`grep "Job Status:" .status | sed -e "s#Job Status: ##g"`

if [ x"Complete" = x"$STATUS"  ] ; then
    echo "YAY! $STATUS"
    curl -o plain_output.yaml https://lava.automotivelinux.org/scheduler/job/$MYJOB/log_file/plain
    cat plain_output.yaml | grep '"target",' | sed -e 's#- {"dt".*"lvl".*"msg":."##g' -e 's#"}$##g'

    # cleanup
    #ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 rm -rf /srv/download/AGL/upload/ci/${CHID}/

    exit 0
else
    echo "Nooooooooo! $STATUS"
    curl -o plain_output.yaml https://lava.automotivelinux.org/scheduler/job/$MYJOB/log_file/plain
    cat plain_output.yaml | grep '"target",' | sed -e 's#- {"dt".*"lvl".*"msg":."##g' -e 's#"}$##g'

    # cleanup
    #ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 rm -rf /srv/download/AGL/upload/ci/${CHID}/

    exit 1
fi
