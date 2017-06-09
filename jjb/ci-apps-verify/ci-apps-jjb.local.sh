#!/bin/bash

#set -x

export GERRIT_REFSPEC="refs/changes/51/9551/2"
export GERRIT_PROJECT="apps/mediaplayer"
export GERRIT_CHANGE_NUMBER="9551"
export GERRIT_PATCHSET_NUMBER="2"
export GERRIT_PATCHSET_REVISION="f3ddc376291262a6b305cc2b0a52792abdc7c85c"
export GERRIT_HOST="gerrit.automotivelinux.org"
export GERRIT_PORT="29418"

export -p > env.save

THISPWD=$(pwd)
for TARGETARCH in aarch64 arm x86-64; do
pushd $THISPWD

for i in `compgen -e | grep -v ^PATH`; do
    unset $i
done

source env.save

#set -x
#export GERRIT_REFSPEC=\"$GERRIT_REFSPEC\"
#export GERRIT_PROJECT=\"$GERRIT_PROJECT\"
#export GERRIT_CHANGE_NUMBER=\"$GERRIT_CHANGE_NUMBER\"
#export GERRIT_PATCHSET_NUMBER=\"$GERRIT_PATCHSET_NUMBER\"
#export GERRIT_PATCHSET_REVISION=\"$GERRIT_PATCHSET_REVISION\"
#export GERRIT_HOST=\"$GERRIT_HOST\"
#export GERRIT_PORT=\"$GERRIT_PORT\"
rm -rf ~/agl-sdk || true

. ../common/include-apps-header.sh
. ../common/include-apps-fetch-install-sdk.sh
. ../common/include-apps-build-app.sh
. ../common/include-apps-rsync-download-changeid.sh

#"

popd

done