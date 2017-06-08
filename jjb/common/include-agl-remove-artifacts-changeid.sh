#!/bin/bash

#set -x
set -e

echo "\n\n\n"
echo "################REMOVE CHANGEID#########################"
echo "\n\n\n"


export DST="/srv/download/AGL/upload/ci/${GERRIT_CHANGE_NUMBER}"
ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 rm -rf ${DST}
