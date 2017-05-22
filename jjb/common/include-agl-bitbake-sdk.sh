# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## bitbake the sdk
################################################################################

# finally, build the agl-demo-platform (we retry to catch the tar-native bug)
#( ( bitbake -c $TARGETSDK $TARGETIMAGE ) || ( echo '## Failed once, retry ..  ##' ; sync ; sleep 2 ; bitbake -c $TARGETSDK $TARGETIMAGE ) ) || ( echo '## Failed again, bail out ... ##' ; exit 1 ) 
( ( bitbake $TARGETSDKIMAGE ) || ( echo '## Failed once, retry ..  ##' ; sync ; sleep 2 ; bitbake $TARGETSDKIMAGE ) ) || ( echo '## Failed again, bail out ... ##' ; exit 1 ) 

du -hs tmp/deploy/*
