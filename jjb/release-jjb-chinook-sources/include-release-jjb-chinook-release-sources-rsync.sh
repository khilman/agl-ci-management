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

#export RSYNCDST="jenkins-slave@10.30.72.8:/srv/download/AGL/release/${RELEASE_BRANCH}/${RELEASE_VERSION}/"
#export RSYNCSRC=$(pwd)/UPLOAD/

# construct upload folder
mv UPLOAD UPLOAD2 || true
rm -rf UPLOAD2 || true
mkdir -p UPLOAD/${MACHINE}
export DEST=$(pwd)/UPLOAD/${MACHINE}

tree $DEST

ls -alhR $DEST


exit 0

if test x"yes" = x"$UPLOAD" ; then
   rsync -avr -e "ssh -o StrictHostKeyChecking=no" $RSYNCSRC $RSYNCDST
fi

exit 0