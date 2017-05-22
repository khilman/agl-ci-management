#!/bin/bash
# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2
#
# debugging purposes
set -e

################################################################################
## Header
################################################################################


# VARIABLES
OPTIND=1
#export DLHOST="http://download.automotivelinux.org/"
# DLHOST in auto.conf
export NOGFX=false
export VERBOSE=false
export DEBUG=false
function vprint() {
    :
}
function dprint() {
    :
}

# defaults for project, branch, refspec
export TARGETPROJECT="AGL/AGL-repo"
export TARGETBRANCH="master"
export TARGETREFSPEC="refs/heads/master"

export TARGETFEATURESnogfx="agl-appfw-smack agl-netboot agl-devel"
export TARGETFEATURES="agl-demo ${TARGETFEATURESnogfx}"

export TARGETQA=""
export TARGETIMAGE="agl-demo-platform\${TARGETQA}"
export TARGETIMAGEnogfx="core-image-minimal"

export TARGETSDK="populate_sdk"
export TARGETSDKIMAGE="agl-demo-platform-crosssdk"

export TARGETMACHINE=${MACHINE}
if test x"porter-nogfx" = x"${MACHINE}" ; then
  export TARGETMACHINE="porter"
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

if test x"" = x"${MACHINE}"; then
    export MACHINE="qemux86-64"
fi

# finally cmdline arguments
while getopts ":b:i:p:r:dnqvx" opt; do
    case "$opt" in
	b)
	    export TARGETBRANCH="$OPTARG"
	    ;;
	d)
	    DEBUG=true
	    function dprint() {
		echo "DEBUG: $@"
	    }
	    ;;
	i)
	    export TARGETIMAGE="$OPTARG"
	    ;;
	n)
	    export NOGFX=true
	    ;;
	p)
	    export TARGETPROJECT="$OPTARG"
	    ;;
	q)
	    export TARGETQA="-qa"
	    ;;
	r)
	    export TARGETREFSPEC="$OPTARG"
	    ;;
	v)
	    VERBOSE=true
	    function vprint() {
		echo "VERBOSE: \"$@\""
	    }
	    ;;
	x)
	    set -x
	    ;;
	h|\?)
	    echo "$0 [-h/-?] -bdinpqrvx"
	    echo "--------------------------------------------------------------------------------"
	    echo "  -b <branch>  - name of the branch to use          (default=master)"
	    echo "  -d           - debug"
	    echo "  -i <image>   - name of the image to build         (default=agl-demo-platform)"
	    echo "  -n           - no graphics (no wayland, aka no drivers)"
	    echo "  -p <project> - project to use                     (default=AGL/AGL-repo)"
	    echo "  -q           - build '*-qa' images                (default='')"
	    echo "  -r <refspec> - refspec to use                     (default=refs/heads/master)"
	    echo "  -v           - verbose"
	    echo "  -x           - set -x"
	    echo "--------------------------------------------------------------------------------"
	    echo "  GERRIT_PROJECT, GERRIT_BRANCH, GERRIT_REFSPEC are used if present,"
	    echo "  but cmdline arguments take precedence."
	    echo "--------------------------------------------------------------------------------"
	    exit 1
	    ;;
	:)
	    echo "Option -$OPTARG required an argument."
	    exit 1
	    ;;
    esac
done

# expand
eval TARGETIMAGE="$TARGETIMAGE"
eval TARGETIMAGEnogfx="$TARGETIMAGEnogfx"

if $NOGFX; then
    export TARGETIMAGE=${TARGETIMAGEnogfx}
    export TARGETFEATURES="${TARGETFEATURESnogfx}"
fi
if test x"porter-nogfx" = x"$MACHINE"; then
    export TARGETIMAGE=${TARGETIMAGEnogfx}
    export TARGETFEATURES="${TARGETFEATURESnogfx}"
fi

#if $DEBUG; then
set | grep ^TARGET || true
set | grep ^GERRIT || true
set | grep ^MACHINE || true
#fi

set -x

#rm -rf ~/.gitconfi* || true

if test ! -f ~/.gitconfig ; then 
  git config --global user.email "jenkins-dontreply@build.automotivelinux.org"
  git config --global user.name "jenkins-dontreply@build.automotivelinux.org"
fi

#git config --global user.email "jenkins-dontreply@build.automotivelinux.org"
#sync
#sleep 1
#ls -alh ~/.gitconfi*
#rm -rf ~/.gitconfig.lock || true
#git config --global user.name "jenkins-dontreply@build.automotivelinux.org"

set +x
