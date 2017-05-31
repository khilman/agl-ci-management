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

cd repoclone/output

export REMOTEDST="/srv/download/AGL/upload/ci/${RELEASE_BRANCH}/${RELEASE_VERSION}/${MACHINE}/"
export RSYNCDST="jenkins-slave@10.30.72.8:${REMOTEDST}"
export RSYNCSRC=$(pwd)/UPLOAD/${MACHINE}

# construct upload folder
mv UPLOAD UPLOAD2 || true
rm -rf UPLOAD2 || true
mkdir -p UPLOAD/${MACHINE}
export DEST=$(pwd)/UPLOAD/${MACHINE}

# save space ... remove the rpms
rm -rf tmp/deploy/rpm || true

rsync -avr --progress --delete tmp/deploy $DEST/
rsync -avr --progress --delete tmp/log $DEST/

cp ../../current_default.xml $DEST/${MACHINE}_repo_default.xml
cp conf/local.conf $DEST/local.conf
cp conf/auto.conf $DEST/auto.conf
echo "$BUILD_URL" > $DEST/jenkins.build.url

tree $DEST

ls -alhR $DEST



echo "would do rsync -avr -e \"ssh -o StrictHostKeyChecking=no\" $RSYNCSRC $RSYNCDST "

if test x"yes" = x"$UPLOAD" ; then
   ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 mkdir -p ${REMOTEDST}
   rsync --delete -avr -e "ssh -o StrictHostKeyChecking=no" $RSYNCSRC/* $RSYNCDST
fi

exit 0