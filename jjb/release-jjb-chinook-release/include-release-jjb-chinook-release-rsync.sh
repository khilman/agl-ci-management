#!/bin/bash

#set -x
set -e

if test x"" = x"${RELEASE_BRANCH}"; then
    echo "RELEASE_BRANCH invalid"
    exit 1
fi

if test x"" = x"${RELEASE_VERSION}"; then
    echo "RELEASE_VERSION invalid"
    exit 1
fi

if test x"" = x"${MACHINE}"; then
    echo "MACHINE invalid"
    exit 1
fi

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

export REMOTEDST="/srv/download/AGL/release/${RELEASE_BRANCH}/${RELEASE_VERSION}/"
export RSYNCDST="jenkins-slave@10.30.72.8:${REMOTEDST}"
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
   ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 mkdir -p ${REMOTEDST}
   rsync -avr -e "ssh -o StrictHostKeyChecking=no" $RSYNCSRC $RSYNCDST
   ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 sh -c "cd /srv/download/AGL/release/${RELEASE_BRANCH}/ ; rm latest ; ln -sf ${RELEASE_VERSION} latest ; echo ${RELEASE_VERSION} > latest.txt" || true
fi

exit 0