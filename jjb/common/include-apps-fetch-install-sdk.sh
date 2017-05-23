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

SDKBASEURL="https://download.automotivelinux.org/AGL/snapshots/master/latest/${TARGETSDKMACHINE}/deploy/sdk/"
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

eval export TARGETSDKENVSCRIPT="${SDKHOSTDIR}/environment-setup-${TARGETSDKARCH}-agl-linux-gnueabi"

if test ! -f ${TARGETSDKENVSCRIPT} ; then
  bash ${TARGETSDKNAME} -d ${SDKHOSTDIR}/ -y
fi
if test ! -f ${TARGETSDKENVSCRIPT} ; then
  echo "Script not there after extracting sdk ?!"
  echo "Abort."
  exit 1
fi

source "${TARGETSDKENVSCRIPT}"

ls -alh ~/

ls

ls -alh

set