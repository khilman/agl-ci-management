#!/bin/bash

#set -x
set -e

#ls -alh

export RSYNCSRC="$(pwd)/mirror/"
export RSYNCDST="jenkins-slave@10.30.72.8:/srv/download/AGL/mirror/"

echo " rsync -avr -e \"ssh -o StrictHostKeyChecking=no\" $RSYNCSRC $RSYNCDST "

if x"true" = x"$UPLOAD" ; then
echo upload
fi

exit 0