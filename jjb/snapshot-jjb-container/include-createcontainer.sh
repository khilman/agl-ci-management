#!/bin/bash

#set -x
set -e
#

git clone https://gerrit.automotivelinux.org/gerrit/AGL/docker-worker-generator
cd docker-worker-generator/

# dump where we are in jenkins log :)
git log -n 1

make build
make export

ls

echo "###########################"

mkdir ../container
mv docker_agl_worker*.tar.xz ../container/

ls ../container

echo "###########################"

