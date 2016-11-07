# (c) 2016 Jan-Simon Moeller, dl9pf(at)gmx.de
# License: GPLv2

################################################################################
## Main
################################################################################

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

