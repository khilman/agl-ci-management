
# Throttle threads to 6
cat << EOF >> conf/auto.conf

BB_NUMBER_THREADS = "5"
BB_NUMBER_PARSE_THREADS = "8"
PARALLEL_MAKE = "-j5"

EOF
