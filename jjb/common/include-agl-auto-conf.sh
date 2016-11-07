# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Main
################################################################################

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
