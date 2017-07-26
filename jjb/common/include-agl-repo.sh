# (c) 2016 Jan-Simon Moeller, dl9pf(at)gmx.de
# License: GPLv2

################################################################################
## Repo init/sync
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

export REPODIR=`pwd`

if test x"" = x"${RELEASE_VERSION}" -a x"" = x"${RELEASE_BRANCH}" ; then
  if test x"AGL/meta-renesas-rcar-gen3" = x"${TARGETPROJECT}" ; then
    repo init --reference=/opt/AGL/preclone -q -b master -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
  else
    repo init --reference=/opt/AGL/preclone -q -b $TARGETBRANCH -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
  fi
else
  repo init --reference=/opt/AGL/preclone -q -b $TARGETBRANCH -m ${RELEASE_BRANCH}_${RELEASE_VERSION}.xml -u https://gerrit.automotivelinux.org/gerrit/AGL/AGL-repo
fi


# next: repo sync and dump manifest
repo sync --force-sync --detach --no-clone-bundle

