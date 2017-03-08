#!/bin/bash

#set -x
set -e
#export RSYNCDST="jenkins-slave@10.30.72.8:/srv/download/AGL/release/${RELEASE_BRANCH}/${RELEASE_VERSION}/"
#export RSYNCSRC=$(pwd)/UPLOAD/

# construct upload folder


BRANCH=${RELEASE_BRANCH}
RELVER=${RELEASE_VERSION}

rm -rf release-upload || true

git clone -b ${RELEASE_BRANCH} https://gerrit.automotivelinux.org/gerrit/p/staging/release-upload.git
cd release-upload

gpg --keyserver pgp.mit.edu --recv D6DD2170

ls | grep -q agl-${RELEASE_BRANCH}-${RELEASE_VERSION}.tar.bz2

( gpg --verify agl-${RELEASE_BRANCH}-${RELEASE_VERSION}.tar.bz2.sig agl-${RELEASE_BRANCH}-${RELEASE_VERSION}.tar.bz2 2>&1 | grep -e "Good signature.*Jan-Simon.*Moeller.*AGL.*Release" -q && echo "gpg key verification succeeded" ) || ( echo "gpg key verification failed" && exit 1 )

rm -rf ../UPLOAD || true
mkdir -p ../UPLOAD/

cp -ar agl-${RELEASE_BRANCH}-${RELEASE_VERSION}.* ../UPLOAD/

export RSYNCSRC=$(pwd)/../UPLOAD
export RSYNCDST="jenkins-slave@10.30.72.8:/srv/download/AGL/release/${RELEASE_BRANCH}/"

if test x"yes" = x"${UPLOAD}" ; then
   rsync -avr -e "ssh -o StrictHostKeyChecking=no" ${RSYNCSRC}/* ${RSYNCDST}
fi
