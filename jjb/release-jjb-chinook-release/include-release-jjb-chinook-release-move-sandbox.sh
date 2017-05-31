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


export REMOTESRC="/srv/download/AGL/upload/ci/${RELEASE_BRANCH}/${RELEASE_VERSION}/"
export REMOTEDST="/srv/download/AGL/release/${RELEASE_BRANCH}/${RELEASE_VERSION}/"

if test x"yes" = x"$UPLOAD" ; then
   ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 mkdir -p ${REMOTEDST}
   ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 mv ${REMOTESRC}/* ${REMOTEDST}/
   ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 rm -r ${REMOTESRC}
   ssh -o StrictHostKeyChecking=no jenkins-slave@10.30.72.8 sh -c "cd /srv/download/AGL/release/${RELEASE_BRANCH}/ ; rm latest ; ln -sf ${RELEASE_VERSION} latest ; echo ${RELEASE_VERSION} > latest.txt" || true
fi

exit 0