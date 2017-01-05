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

export RSYNCDST="jenkins-slave@10.30.72.8:/srv/download/AGL/release/${RELEASE_BRANCH}/${RELEASE_VERSION}/"
export RSYNCSRC=$(pwd)/UPLOAD/

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
   rsync -avr --delete -e "ssh -o StrictHostKeyChecking=no" $RSYNCSRC $RSYNCDST
fi

exit 0