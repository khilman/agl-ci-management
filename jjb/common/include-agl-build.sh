#!/bin/bash
# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2
#
# debugging purposes
set -e

# VARIABLES
OPTIND=1
export DLHOST="https://download-new.automotivelinux.org/"
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

export TARGETFEATURESnogfx="agl-appfw-smack agl-netboot agl-sota agl-devel"
export TARGETFEATURES="agl-demo ${TARGETFEATURESnogfx}"

export TARGETQA=""
export TARGETIMAGE="agl-demo-platform\${TARGETQA}"
export TARGETIMAGEnogfx="core-image-minimal"

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
fi
if test x"porter-nogfx" = x"$MACHINE"; then
    export TARGETIMAGE=${TARGETIMAGEnogfx}
fi

if $DEBUG; then
set | grep ^TARGET || true
set | grep ^GERRIT || true
set | grep ^MACHINE || true
fi


# create shared downloads and sstate-cache directory
mkdir -p downloads
mkdir -p sstate-cache

# remove old files, we want to test a fresh clone
export XTMP="$$"
mv repoclone repoclone$XTMP || true
( rm -rf repoclone$XTMP & ) || true
mkdir -p repoclone
cd repoclone

repo init --reference=/opt/AGL/preclone -q -b $TARGETBRANCH -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo

# next: repo sync and dump manifest
repo sync --force-sync --detach --no-clone-bundle

# fix up this branch
MYPROJECT=`echo $TARGETPROJECT | sed -e "s#AGL/##g"`


if test -n "${GERRIT_CHANGE_NUMBER}" -a -n "${GERRIT_PATCHSET_NUMBER}"  ; then
    repo download $MYPROJECT ${GERRIT_CHANGE_NUMBER}/${GERRIT_PATCHSET_NUMBER}
else
    if test x"AGL-repo" = x"$MYPROJECT" ; then
	cd .repo/manifests
        MYREMOTE=`git remote | head -1`
        git fetch ${MYREMOTE} ${TARGETREFSPEC}
        git reset --hard FETCH_HEAD
	cd ../../
	repo sync --force-sync -d
    else
	cd $MYPROJECT
	MYREMOTE=`git remote | head -1`
	git fetch ${MYREMOTE} ${TARGETREFSPEC}
	git reset --hard FETCH_HEAD
	cd ..
    fi
fi

repo manifest -r
repo manifest -r > ../current_default.xml

# source the env
source meta-agl/scripts/aglsetup.sh -m ${MACHINE} -b output ${TARGETFEATURES}

# link the shared downloads and sstate-cache
ln -sf ../../downloads
ln -sf ../../sstate-cache

echo "" >> conf/local.conf

#limit parallel number of bitbake jobs and parallel jobs in make
cat << EOF > conf/auto.conf
PREMIRRORS = "\
git://.*/.* ${DLHOST}/AGL/mirror/   \n \
ftp://.*/.* ${DLHOST}/AGL/mirror/   \n \
http://.*/.* ${DLHOST}/AGL/mirror/  \n \
https://.*/.* ${DLHOST}/AGL/mirror/ \n \
             "

SSTATE_MIRRORS = "\
file://.* file:///opt/AGL/sstate-mirror/\${MACHINE}/PATH    \n \
file://.* ${DLHOST}/sstate-mirror/\${MACHINE}/PATH \n \
                 "

SSTATE_DIR = "\${TOPDIR}/sstate-cache/\${MACHINE}/"
EOF

cat conf/auto.conf

# finally, build the agl-demo-platform
bitbake $TARGETIMAGE

du -hs tmp/deploy/*
