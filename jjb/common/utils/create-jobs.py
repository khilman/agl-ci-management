#!/usr/bin/env python

import os
import glob
from jinja2 import Environment, FileSystemLoader
import random
import string

nbd = True

# FIXME: hard-coded for rpi3
yocto_machine = "raspberrypi3"
kernel_image = "uImage"
rootfs = "agl-demo-platform-%s.ext4.xz" % yocto_machine
initrd = "initramfs-netboot-image-%s.ext4.gz.u-boot" % yocto_machine
dtb = "uImage-bcm2710-rpi-3-b.dtb"

template_file = os.path.join("boot", "generic-uboot-tftp.jinja2")
job_file = "testjob.yaml"
random_id = ''.join(random.choice(string.ascii_uppercase + string.digits) for _ in range(8))

job = {}
job['name'] = "AGL template test job. ID %s" % random_id
job['priority'] = 'medium'
job['template_file'] = template_file
job['yocto_machine'] = yocto_machine

# FIXME: AGL lab device_type names are fsck'd up
job['device_type'] = "%s-uboot" % yocto_machine

url_base = "http://www.baylibre.com/pub/agl/ci/%s/" % yocto_machine
job['kernel_image'] = kernel_image
job['kernel_url'] = url_base + kernel_image
job['boot_type'] = "bootm"

# Tests to iclude
job['test_templates'] = [
    os.path.join("tests", "test1.jinja2"),
    os.path.join("tests", "test2.jinja2"),
]

# NBD jobs
if nbd:
    job['use_nbd'] = True
    job['boot_commands'] = "nbd"
    job['deploy_to'] = "nbd"
    job['nbdroot_url'] = url_base + rootfs
    job['nbd_initrd_url'] = url_base + initrd
    job['dtb_url'] = url_base + dtb

# QEMU jobs
elif qemu:
    qemu_args = "-cpu qemu64,+ssse3,+sse4.1,+sse4.2,+popcnt -m 1048 -soundhw hda"
    qemu_cmdline = "console=ttyS0,115200 root=/dev/hda debug verbose"
    job['use_qemu'] = True
    job['boot_method'] = "qemu"
    job['deploy_to'] = "tmpfs"

def jinja_render(job):
    env = Environment(loader=FileSystemLoader('templates'))
    template = env.get_template(job['template_file'])
    return template.render(job)

def main():
    with open(job_file, 'w') as f:
        f.write(jinja_render(job))
    print "Job written: %s" % job_file

if __name__ == '__main__':
    main()
    
