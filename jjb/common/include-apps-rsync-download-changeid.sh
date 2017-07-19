#!/bin/bash

#set -x
set -e

echo -e "\n\n\n"
echo "#########################################"
echo -e "\n\n\n"


export RSYNCDST="/srv/download/AGL/upload/ci/${GERRIT_CHANGE_NUMBER}/${GERRIT_PATCHSET_NUMBER}"
export RSYNCSRC=$(pwd)/UPLOAD/

# construct upload folder
#mv UPLOAD UPLOAD2 || true
rm -rf UPLOAD/${TARGETARCH} || true
mkdir -p UPLOAD/${TARGETARCH}
export DEST=$(pwd)/UPLOAD/${TARGETARCH}

pushd ${MYPROJECT}
ls
ls package

cp package/*.wgt $DEST
ls -alh $DEST
LANG=C tree $RSYNCSRC

popd
ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 mkdir -p ${RSYNCDST}
rsync -avr -L -e "ssh -o StrictHostKeyChecking=no" $RSYNCSRC jenkins-slave@10.30.72.8:$RSYNCDST
