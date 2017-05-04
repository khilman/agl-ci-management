
FOR AGL-test-slave use:

~/bin/packer build
-var-file=vars/cloud-env.json \
-var-file=vars/ubuntu-16.04.json \
-var-file=vars/lava-env.json \
templates/basebuild-agl-test-slave.json > ~/Downloads/packer.test.log



FOR AGL-control-slave use:



~/bin/packer build \
-var-file=vars/cloud-env.json \
-var-file=vars/ubuntu-16.04.json \
-var-file=vars/lava-env.json \
templates/basebuild-control-slave.json  > ~/Downloads/packer.control.log
