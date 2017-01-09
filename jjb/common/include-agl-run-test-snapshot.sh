# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Run SHORT CI test
################################################################################

# test currently only for porter, rest WIP
echo "## ${MACHINE} ##"


echo "default keyring config"

mkdir -p ~/.local/share/python_keyring/

cat <<EOF >  ~/.local/share/python_keyring/keyringrc.cfg
[backend]
default-keyring=keyring.backends.file.PlaintextKeyring
EOF

cat <<EOF > ~/.local/token
$AGLLAVATOKEN
EOF

lava-tool auth-add --token-file ~/.local/token https://agl-jenkins-user@porter.automotivelinux.org

cat ~/.local/token

cat <<EOF > testjob.yaml
# Your first LAVA JOB definition for a porter board
device_type: renesas-porter-uboot
job_name: renesas-porter-uboot

protocols:
  lava-xnbd:
    port: auto

timeouts:
  job:
    minutes: 15
  action:
    minutes: 5
  connection:
    minutes: 2
priority: medium
visibility: public

# ACTION_BLOCK
actions:
- deploy:
    to: nbd
    dtb:
      url: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/uImage-r8a7791-porter.dtb'
    kernel:
      url: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/uImage'
    initramfs:
      url: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/initramfs-netboot-image-porter.ext4.gz.u-boot'
      allow_modify: false
    nbdroot:
      url: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/core-image-minimal-porter.ext4'
    os: debian
    failure_retry: 2


# BOOT_BLOCK
- boot:
    method: u-boot
    commands: nbd
    type: bootm
    prompts: ["root@porter:~"]
    auto_login:
      login_prompt: "login:"
      username: root

EOF

#rm ~/.local/token

lava-tool submit-job https://agl-jenkins-user@porter.automotivelinux.org testjob.yaml

# setup 