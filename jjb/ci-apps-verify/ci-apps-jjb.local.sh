#!/bin/bash

set -x

export GERRIT_REFSPEC="refs/changes/49/9549/2"
export GERRIT_PROJECT="apps/mediaplayer"
export GERRIT_CHANGE_NUMBER="9549"
export GERRIT_PATCHSET_NUMBER="2"
export GERRIT_PATCHSET_REVISION="b0f682b1579e520896ccd5492d6666d962a0c226"
export GERRIT_HOST="gerrit.automotivelinux.org"
export GERRIT_PORT="29418"

. ../common/include-apps-header.sh
. ../common/include-apps-fetch-install-sdk.sh
. ../common/include-apps-build-app.sh
