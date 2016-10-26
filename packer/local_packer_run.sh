#!/bin/bash
packer build -var-file=vars/lava-env.json -var-file=vars/ubuntu-16.04.json -var-file=vars/cloud-env.json templates/basebuild-local-kvm.json 
