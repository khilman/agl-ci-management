#!/bin/bash

# debugging purposes
set -e
set -x
echo "#####################################################################"
set
echo "#####################################################################"


# repo https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
repo init -b blowfish -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
repo sync --force-sync

# save current manifest
repo manifest -r > ${MACHINE}_default.xml

# clean it up
mv agl-blowfish-$MACHINE agl-blowfish-${MACHINE}_2 || true
ionice rm -rf agl-blowfish-${MACHINE}_2 &

echo "#####################################################################"

# create shared downloads and sstate-cache
mkdir -p ../downloads
mkdir -p ../sstate-cache

# source the env
source meta-agl/scripts/envsetup.sh $MACHINE agl-blowfish-$MACHINE

# only if sequential - global dl/sstate-cache !
#ln -sf ../../downloads
#ln -sf ../../sstate-cache

#echo "" >> conf/local.conf
#echo 'INHERIT += "rm_work"' >> conf/local.conf

# archive sources within  tmp/deploy/
echo 'INHERIT += "archiver"' >> conf/local.conf
echo 'ARCHIVER_MODE[src] = "original"' >> conf/local.conf

# isafw
# meta-security-isafw
echo "BBLAYERS += \" $(pwd)/../meta-security-isafw \" " >> conf/bblayers.conf
echo "INHERIT += \"isafw\" " >> conf/local.conf

echo 'IMAGE_INSTALL_append = " ALS2016-demo CES2016-demo mc"' >> conf/local.conf

if test x"qemux86" == x"$MACHINE" -o x"qemux86-64" == x"$MACHINE" ; then
 echo 'IMAGE_FSTYPES = "tar.bz2 vmdk"' >> conf/local.conf
fi

#echo 'INSANE_SKIP_nativesdk-dbus = "installed-vs-shipped"' >> conf/local.conf


# build it
bitbake agl-demo-platform
bitbake agl-demo-platform-crosssdk

#bitbake -c populate_sdk agl-demo-platform

# prepare RELEASE dir for rsyncing



mv RELEASE RELEASE2 || true
( ionice rm -rf RELEASE2 || true ) &
mkdir -p RELEASE/blowfish/${RELEASEVERSION}/${MACHINE}
export DEST=$(pwd)/RELEASE/blowfish/${RELEASEVERSION}/${MACHINE}
export RSYNCSRC=$(pwd)/RELEASE/
export RSYNCDST="127.0.0.1::repos/release/"

rsync -avr --progress --delete tmp/deploy/ $DEST/
rsync -avr --progress --delete tmp/log $DEST/

cp ../${MACHINE}_default.xml $DEST/${MACHINE}_repo_default.xml
cp conf/local.conf $DEST/local.conf
echo "$BUILD_URL" > $DEST/jenkins.build.url

#debug
tree $DEST

echo "NOT DOING RSYNC, yet"

exit 0

if false ; then
# rsync to download server
rsync -avr $RSYNCSRC $RSYNCDST

# create latest symlink
pushd $RSYNCSRC/blowfish/
rm -rf latest || true
ln -sf ${RELEASEVERSION} latest
echo "${RELEASEVERSION}" > latest.txt
popd

#resync with link
rsync -alvr $RSYNCSRC $RSYNCDST

fi