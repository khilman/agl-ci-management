# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Main
################################################################################

# test currently only for porter, rest WIP
TESTRUN=false
echo "## $MACHINE ##"

case $MACHINE in
    porter-nogfx)
        TESTRUN=true
        ;;
    porter)
        TESTRUN=true
        ;;
    *)
        TESTRUN=false
        ;;
esac


if $TESTRUN; then

echo "TBD"

fi