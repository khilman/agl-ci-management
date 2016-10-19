#!/bin/bash

#set -x
set -e
#
export BOARDS="qemux86-64 qemux86 raspberrypi3 dra7xx-evm dragonboard-410c intel-corei7-64 wandboard"
export FEATURES="agl-demo agl-appfw-smack agl-netboot agl-sota agl-devel"
export FEATURES_nogfx="agl-appfw-smack agl-netboot agl-sota agl-devel"
export TARGETIMAGE="agl-demo-platform"
export TARGETIMAGE_nogfx="agl-image-ivi-qa"

mkdir -p mirror
mkdir -p sstate

mv repoclone repoclone2 > /dev/null 2>&1 || true
rm -rf repoclone2 || true
mkdir -p repoclone
cd repoclone

repo init --reference=/opt/AGL/preclone -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo.git
repo sync -j8

for i in $BOARDS ; do
    pushd .

    if test x"porter-nogfx" = x"$i" ; then
	FEATURES="${FEATURES_nogfx}"
	TARGETIMAGE="${TARGETIMAGE_nogfx}"
    fi
    source meta-agl/scripts/aglsetup.sh -m ${i} -b build-${i} ${FEATURES}
    ln -sf ../../mirror downloads
    ln -sf ../../sstate sstate-cache
    echo 'BB_GENERATE_MIRROR_TARBALLS = "1"' >> conf/local.conf
    #recipe tar-native-1.28-r0: task do_populate_sysroot_setscene
    bitbake -k tar-native
    bitbake -c fetchall ${TARGETIMAGE}
    popd
done

#ls ../mirror || true
