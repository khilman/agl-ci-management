#!/bin/bash
# (c) 2017 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2
#
# debugging purposes
set -e

SDKHOSTDIR="~/agl-sdk"

################################################################################
## apps-fetch-install-sdk.sh
################################################################################

# default to master
SDKBASEURL="https://download.automotivelinux.org/AGL/snapshots/master/latest/${TARGETSDKMACHINE}/deploy/sdk/"

# should probably switch to release ... or multiple (release/snapshot) fwiw
if test x"" = x"$AGLBRANCH"; then echo "AGLBRANCH not set, quitting" ; exit 1 ; fi

if test x"master" = x"$AGLBRANCH" ; then
  SDKBASEURL="https://download.automotivelinux.org/AGL/snapshots/master/latest/${TARGETSDKMACHINE}/deploy/sdk/"
fi
if test x"chinook" = x"$AGLBRANCH" ; then
  SDKBASEURL="https://download.automotivelinux.org/AGL/release/chinook/latest/${TARGETSDKMACHINE}/deploy/sdk/"
fi
if test x"dab" = x"$AGLBRANCH" ; then
  SDKBASEURL="https://download.automotivelinux.org/AGL/release/dab/latest/${TARGETSDKMACHINE}/deploy/sdk/"
fi


export TARGETSDKNAME=$(curl -s "$SDKBASEURL" | grep -e "crosssdk.*\.sh<" | sed -e "s#.*<a href=\"##g" -e "s#\">poky-agl.*##g")

if test x"" = x"${TARGETSDKNAME}" ; then
    echo "Could not retrieve TARGETSDKNAME from download.automotivelinux.org"
    echo "Abort."
    exit 1
fi

if test ! -f ${TARGETSDKNAME} ; then
  echo "Downloading $TARGETSDKNAME for $MACHINE"
  wget -nd -c "${SDKBASEURL}/${TARGETSDKNAME}"
fi

chmod a+x ${TARGETSDKNAME}

if test x"" = x"$(eval ls ${SDKHOSTDIR}/environment-setup* | grep "agl-" | grep ${TARGETSDKARCH} 2>/dev/null)" ; then
  bash ${TARGETSDKNAME} -d ${SDKHOSTDIR}/ -y
fi

# find out the env setup script
export TARGETSDKENVSCRIPT="$(eval ls ${SDKHOSTDIR}/environment-setup* | grep "agl-" | grep ${TARGETSDKARCH} 2>/dev/null)"

if test ! -f ${TARGETSDKENVSCRIPT} ; then
  echo "Script not there after extracting sdk ?!"
  echo "Abort."
  exit 1
fi

echo "About to source ${TARGETSDKENVSCRIPT}"
source "${TARGETSDKENVSCRIPT}"

