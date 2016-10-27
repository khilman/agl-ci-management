#!/bin/bash
# vim: sw=2 ts=2 sts=2 et :

set -x

cat /etc/apt/sources.list

# Make sure that we aren't using the vexxhost mirrors as they have issues
echo "---> Removing Vexxhost Ubuntu mirrors"
sed -i 's/ubuntu.mirror.vexxhost.com/us.archive.ubuntu.com/g' /etc/apt/sources.list

cat /etc/apt/sources.list

DEBIAN_FRONTEND=noninteractive apt-get update && apt-get -y -u dist-upgrade

DEBIAN_FRONTEND=noninteractive apt-get update && \
    apt-get -y install gawk wget git-core diffstat unzip texinfo gcc-multilib build-essential chrpath socat \
                       libsdl1.2-dev xterm make xsltproc docbook-utils fop dblatex xmlto autoconf automake \
                       libtool libglib2.0-dev libarchive-dev python-git git python python-minimal repo \
                       tree rsync python-yaml python-requests curl tar docker pandoc

# we have a build blocker wrt useradd - I assume it is caused by /bin/sh being dash
# systemd: Performing useradd with
echo "dash dash/sh boolean false" | debconf-set-selections
DEBIAN_FRONTEND=noninteractive dpkg-reconfigure dash

cat <<EOFHOSTS >> /etc/hosts

# workaround for download-new
199.19.213.77 download-new.automotivelinux.org
10.30.72.8 download-internal.automotivelinux.org

EOFHOSTS


cat <<EOFSYSCTL >> /etc/sysctl.conf
# we have a lot of make jobs, this helps a lot
kernel.sched_child_runs_first = 1
# smooth over a lot of I/O requests and do less blocking
vm.dirty_background_bytes = 0
vm.dirty_background_ratio = 20
vm.dirty_expire_centisecs = 4320000
vm.dirtytime_expire_seconds = 432000
vm.dirty_bytes = 0
vm.dirty_ratio = 80
vm.dirty_writeback_centisecs = 0


EOFSYSCTL

# clone lava-boot to /opt/AGL/
mkdir -p /opt/AGL/
cd /opt/AGL/
git clone http://git.linaro.org/people/riku.voipio/lava-boot.git
cd lava-boot
sed -i '16iimport ssl' lava-boot
sed -i '17issl._create_default_https_context = ssl._create_unverified_context' lava-boot

# AGL specific lab integration. To be moved into git repo and cloned or the like.
#################################################################################
mkdir -p /opt/AGL/lava-agl/
cat <<EOFBR >> /opt/AGL/lava-agl/boardready.py
#!/usr/bin/python
import xmlrpclib
import ssl
import sys
import time

# bug, ssl chain cannot be verified (letsencrypt)
# to be fixed
ssl._create_default_https_context = ssl._create_unverified_context

username = "$LAVAUSER"
token = "$LAVATOKEN"
myhostname = "$LAVAHOST"

print "Starting ..."
sys.stdout.flush()
arg = None
if len(sys.argv) > 1:
        arg = sys.argv[1]

if arg == None:
        print("No argument, need lava jobnumber as argument.")
        sys.stdout.flush()
        sys.exit(1)

server = xmlrpclib.ServerProxy("https://%s:%s@%s/RPC2" % (username, token, myhostname))
#print(arg)
#sys.stdout.flush()

# Poll loop
while True:
        try:
            x = server.scheduler.job_status(arg)['job_status']
        except:
            print("Error, quitting.")
            sys.stdout.flush()
            sys.exit(1)
            break
        if 'Cancelled' in x:
                sys.exit(1)
                break
        if 'Submitted' in x:
                print("Job submitted - pending")
                sys.stdout.flush()
                time.sleep(20)
                continue
        if 'Running' in x:
                print("Job Running now.")
                print("Remote boot takes around 5 minutes to complete (download+boot) - waiting ...")
                sys.stdout.flush()
                time.sleep(300)
                y = server.scheduler.job_status(arg)['job_status']
                if 'Running' in y:
                        break
                else:
                        continue
                break
        break
# end
EOFBR

cat <<EOFLAVAYAML > /opt/AGL/lava-agl/.lava.yaml
server: ${LAVAHOST}
user: ${LAVAUSER}
token: ${LAVATOKEN}
https: true
EOFLAVAYAML

cat <<EOFPORTERUPLOADYAML > /opt/AGL/lava-agl/porter_nbd_upload.yaml
actions:
    - command: deploy_linaro_kernel
      parameters:
          kernel: 'http://localhost/porter/upload/uImage+dtb'
          nbdroot: 'http://localhost/porter/upload/agl-demo-platform-porter.ext4'
          ramdisk: 'http://localhost/porter/upload/initramfs-netboot-image-porter.ext4.gz.u-boot'
          login_prompt: 'porter login:'
          username: 'root'
    - command: boot_linaro_image
      parameters:
          test_image_prompt: 'root@porter:~#'
    - command: lava_command_run
      parameters:
          commands:
              - "while test ! -f /jta.done ; do echo \"Waiting for JTA to finish ... \" ; sleep 20 ; done"
          timeout: 22100
device_type: 'renesas-porter'
logging_level: INFO
job_name: '\${JOB_NAME}'
timeout: 22600

EOFPORTERUPLOADYAML

cat <<EOFPORTERUPLOADYAML1 > /opt/AGL/lava-agl/porter_nbd_upload_stress.yaml
actions:
    - command: deploy_linaro_kernel
      parameters:
          kernel: 'http://localhost/porter/upload/uImage+dtb'
          nbdroot: 'http://localhost/porter/upload/agl-demo-platform-porter.ext4'
          ramdisk: 'http://localhost/porter/upload/initramfs-netboot-image-porter.ext4.gz.u-boot'
          login_prompt: 'porter login:'
          username: 'root'
    - command: boot_linaro_image
      parameters:
          test_image_prompt: 'root@porter:~#'
    - command: lava_command_run
      parameters:
          commands:
              - "export NR=`grep processor /proc/cpuinfo | wc -l` ; stress -v -t 120 -c \$NR -m \$NR -i \$NR "
          timeout: 300
device_type: 'renesas-porter'
logging_level: INFO
job_name: '\${JOB_NAME}'
timeout: 22600

EOFPORTERUPLOADYAML1

cat <<EOFPORTERSNAPYAML > /opt/AGL/lava-agl/porter_nbd_snapshot.yaml
actions:
    - command: deploy_linaro_kernel
      parameters:
          kernel: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/uImage+dtb'
          nbdroot: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/core-image-minimal-porter.ext4'
          ramdisk: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/initramfs-netboot-image-porter.ext4.gz.u-boot'
          login_prompt: 'porter login:'
          username: 'root'
    - command: boot_linaro_image
      parameters:
          test_image_prompt: 'root@porter:~#'
    - command: lava_command_run
      parameters:
          commands:
              - "while test ! -f /jta.done ; do echo \"Waiting for JTA to finish ... \" ; sleep 20 ; done"
          timeout: 22100
device_type: 'renesas-porter'
logging_level: INFO
job_name: '\${JOB_NAME}'
timeout: 22600
EOFPORTERSNAPYAML

cat <<EOFPORTERSNAPYAML1 > /opt/AGL/lava-agl/porter_nbd_snapshot_stress.yaml
actions:
    - command: deploy_linaro_kernel
      parameters:
          kernel: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/uImage+dtb'
          nbdroot: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/core-image-minimal-porter.ext4'
          ramdisk: 'https://download.automotivelinux.org/AGL/snapshots/master/latest/porter-nogfx/deploy/images/porter/initramfs-netboot-image-porter.ext4.gz.u-boot'
          login_prompt: 'porter login:'
          username: 'root'
    - command: boot_linaro_image
      parameters:
          test_image_prompt: 'root@porter:~#'
    - command: lava_command_run
      parameters:
          commands:
              - "export NR=`grep processor /proc/cpuinfo | wc -l` ; stress -v -t 120 -c \$NR -m \$NR -i \$NR "
          timeout: 300
device_type: 'renesas-porter'
logging_level: INFO
job_name: '\${JOB_NAME}'
timeout: 22600
EOFPORTERSNAPYAML1


cat <<EOFUPLOAD > /opt/AGL/lava-agl/upload4lava.sh
#!/bin/bash
#set -x

if test x"" != x"\$1"; then
Y=\$(echo "\$1" | sed -e "s#\.\.##g" -e "s#/##g")
curl -T "\$Y" https://porter.automotivelinux.org/porter/upload/jta/\$Y --insecure
else
echo "Help: \$0 file"
fi

EOFUPLOAD

cat <<EOFDEPLOY > /opt/AGL/lava-agl/deploy.sh
#!/bin/bash
#set -x
set -e
PORTERYAML="porter_nbd_snapshot.yaml"

if test x"" != x"\$1" ; then
    PORTERYAML="\$1"
fi
if test -f /opt/AGL/lava-agl/\${PORTERYAML}; then
    /opt/AGL/lava-agl/boardready.py \$(/opt/AGL/lava-boot/lava-boot -j /opt/AGL/lava-agl/\${PORTERYAML} -a -q | sed -e "s#.*job/##g")
else
    echo "\${PORTERYAML} not found."
    exit 1
fi
EOFDEPLOY

chmod a+x /opt/AGL/lava-agl/*
