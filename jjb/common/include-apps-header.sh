#!/bin/bash
# (c) 2017 Jan-Simon Moeller dl9pf(at)gmx.de
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

#export TARGETARCHALL="arm aarch64 x86-64"
#set | grep arm
#set | grep aarch64
#set | grep x86-64

echo "################################################################################"
set | grep TARGETARCH
echo "################################################################################"
#if test x"" = x"${TARGETARCH}"; then
#    export TARGETARCH="arm"
#fi
#set +x

# finally cmdline arguments
while getopts ":b:a:p:r:dvx" opt; do
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
	p)
	    export TARGETPROJECT="$OPTARG"
	    ;;
	a)
	    export TARGETARCH="arm"
	    ;;
	r)
	    export TARGETREFSPEC="$OPTARG"
	    ;;
	t)
	    export AGLBRANCH="$OPTARG"
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
	    echo " -a            - arch"
	    echo "                 one of:"
	    echo "                 -- arm"
	    echo "                 -- x86-64"
	    echo "                 -- aarch64"
	    echo "  -p <project> - project to use                     (default=AGL/AGL-repo)"
	    echo "  -r <refspec> - refspec to use                     (default=refs/heads/master)"
	    echo "  -t <branch>  - AGL release branch to use          (default=master , e.g. dab)"
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

if test ! -f ~/.gitconfig ; then 
  git config --global user.email "jenkins-dontreply@build.automotivelinux.org"
  git config --global user.name "jenkins-dontreply@build.automotivelinux.org"
fi

##### map architecture to a machine SDK (until we have generic SDKs) #########

if test x"" = x"$TARGETARCH" ; then
  echo "No TARGETARCH variable. Exiting."
  exit 1
fi

case "$TARGETARCH" in 
	arm)
	    export TARGETSDKARCH="armv7vehf-neon-vfpv4"
	    export TARGETSDKMACHINE="raspberrypi3"
	    ;;
	x86-64)
	    export TARGETSDKARCH="corei7-64"
	    export TARGETSDKMACHINE="intel-corei7-64"
	    ;;
	aarch64)
	    export TARGETSDKARCH="aarch64"
	    export TARGETSDKMACHINE="dragonboard-410c"
	    ;;
esac

# failsafe
if test x"" = x"$TARGETSDKARCH" ; then
  echo "No TARGETSDKARCH variable. Exiting."
  exit 1
fi
# failsafe
if test x"" = x"$TARGETSDKMACHINE" ; then
  echo "No TARGETSDKMACHINE variable. Exiting."
  exit 1
fi


echo "################################################################################"
set | grep ^TARGET
echo "################################################################################"
