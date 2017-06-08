#!/bin/bash
# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2
#
# debugging purposes
set -e

################################################################################
# build the app
################################################################################

# fallback
if test -z "${GERRIT_PROJECT}"; then
    export GERRIT_PROJECT="apps/controls"
fi
if test -z "${GERRIT_BRANCH}"; then
    export GERRIT_BRANCH="master"
fi
if test -z "${GERRIT_REFSPEC}"; then
    export GERRIT_REFSPEC="refs/tags/dab_3.99.1"
fi
if test -z "${GERRIT_HOST}"; then
    export GERRIT_HOST="gerrit.automotivelinux.org"
fi

# apply GERRIT_*
if test -n "${GERRIT_PROJECT}"; then
    export TARGETPROJECT="${GERRIT_PROJECT}"
fi
if test -n "${GERRIT_BRANCH}"; then
    export TARGETBRANCH="${GERRIT_BRANCH}"
fi
if test -n "${GERRIT_REFSPEC}"; then
    export TARGETREFSPEC="${GERRIT_REFSPEC}"
fi



HANDLED="no"

# Projects in apps/*
###################
if [[ ! x"yes" = x"$HANDLED" ]] && $(echo "$TARGETPROJECT" | grep -q "apps/"); then

    MYPROJECT=`echo $TARGETPROJECT | sed -e "s#apps/##g"`

    # clone git
    rm -rf ${MYPROJECT}

    git clone https://${GERRIT_HOST}/gerrit/${GERRIT_PROJECT}.git
    pushd ${MYPROJECT}
        git log -1
        git fetch ${TARGET_REFSPEC}
        git reset --hard FETCH_HEAD
        git log -1
        if test -f Makefile ; then
          make
          make package
        fi
        if test -f ${MYPROJECT}.pro; then
          qmake
          make
          make package
        fi
    popd

    HANDLED="yes"
fi
