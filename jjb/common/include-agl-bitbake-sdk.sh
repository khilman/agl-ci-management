# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## bitbake the sdk
################################################################################

# finally, build the agl-demo-platform (we retry to catch the tar-native bug)
bitbake -c $TARGETSDK $TARGETIMAGE || bitbake -c $TARGETSDK $TARGETIMAGE

du -hs tmp/deploy/*
