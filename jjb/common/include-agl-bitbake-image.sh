# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Main
################################################################################

# finally, build the agl-demo-platform (we retry to catch the tar-native bug)
bitbake $TARGETIMAGE || bitbake $TARGETIMAGE

du -hs tmp/deploy/*
