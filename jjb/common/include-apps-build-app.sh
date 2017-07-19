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
    git clone --recursive https://${GERRIT_HOST}/gerrit/${GERRIT_PROJECT}.git
    pushd ${MYPROJECT}
        git log -1 --pretty=oneline
        if test x"" != x"${TARGETREFSPEC}" ; then
          git fetch origin ${TARGETREFSPEC}
          git reset --hard FETCH_HEAD
        else
          # try 
          # GERRIT_CHANGE_NUMBER="9551"
          # GERRIT_PATCHSET_NUMBER="2"
          if ( test x"" != x"${GERRIT_CHANGE_NUMBER}" -a x"" != x"${GERRIT_PATCHSET_NUMBER}" ) ; then
            pip install --user git-review
            git review -d ${GERRIT_CHANGE_NUMBER},${GERRIT_PATCHSET_NUMBER}
          fi
          sleep 2
          # if not reset, we leave it to master
        fi
        git log -1 --pretty=oneline

        # Fixme: use aglbuild script
        set -x
        export DONE=false
        if test ! $DONE -a -f conf.d/autobuild/agl/autobuild ; then
            mkdir -p $(pwd)/package/
            conf.d/autobuild/agl/autobuild package DEST=$(pwd)/package/
            export DONE=true
        fi
        if test ! $DONE -a -f Makefile ; then
            make
            make package
            export DONE=true
        fi
        if test ! $DONE -a -f ${MYPROJECT}.pro; then
            qmake
            make
            make package
            export DONE=true
        fi
    popd

    HANDLED="yes"
fi
