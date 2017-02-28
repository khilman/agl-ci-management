#!/bin/bash

#set -x
set -e
#

git clone https://github.com/iotbzh/agl-docker-worker.git
cd agl-docker-worker/

make build
make export

ls

echo "###########################"

mkdir ../container
mv docker_agl_worker*.tar.xz ../container/

ls ../container

echo "###########################"

