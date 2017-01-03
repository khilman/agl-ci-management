#!/bin/bash

#set -x
set -e
echo "#######################################"
echo "#######################################"
ls -alh
echo "#######################################"
echo "#######################################"
tree -L 2
echo "#######################################"
echo "#######################################"
set | grep MACHINE
echo "#######################################"
echo "#######################################"
set
echo "#######################################"
echo "#######################################"

export RSYNCSRC="$(pwd)/tmp/deploy/images/"
export RSYNCDST="jenkins-slave@10.30.72.8:/srv/download/AGL/release/${RELEASE_BRANCH}/${RELEASE_VERSION}/"

echo "would do rsync -avr -e \"ssh -o StrictHostKeyChecking=no\" $RSYNCSRC $RSYNCDST "

if test x"yes" = x"$UPLOAD" ; then
echo upload
fi

exit 0