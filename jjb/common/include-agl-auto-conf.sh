# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## auto.conf inclusion of mirrors
################################################################################

export DLHOST="http://download.automotivelinux.org/"
if test x"" = x"${GERRIT_BRANCH}"; then
    export DISTROBRANCH="master"
else
    export DISTROBRANCH="${GERRIT_BRANCH}"
fi
#if test ! x"" = x"${RELEASE_BRANCH}"; then
#    export DISTROBRANCH="$RELEASE_BRANCH"
#fi
#limit parallel number of bitbake jobs and parallel jobs in make
cat << EOF >> conf/auto.conf
PREMIRRORS = "\
git://.*/.* ${DLHOST}/AGL/mirror/   \n \
ftp://.*/.* ${DLHOST}/AGL/mirror/   \n \
http://.*/.* ${DLHOST}/AGL/mirror/  \n \
https://.*/.* ${DLHOST}/AGL/mirror/ \n \
             "

SSTATE_MIRRORS = " \
  file://.* ${DLHOST}/sstate-mirror/${DISTROBRANCH}/\${DEFAULTTUNE}/PATH \n \
                 "
#
#file://.* file:///opt/AGL/sstate-mirror/\${MACHINE}/PATH    \n 
#

IMAGE_FSTYPES_remove = "ext3"
SSTATE_DIR = "\${TOPDIR}/sstate-cache/\${MACHINE}/"
EOF
