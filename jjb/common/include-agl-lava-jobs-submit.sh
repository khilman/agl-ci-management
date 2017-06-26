# (c) 2017 Kevin Hilman <khilman@baylibre.com>
# License GPLv2
#
# Submit LAVA YAML job file (default testjob.yaml) to first available LAVA lab
# with matching device-type
#
JOB_FILE=${1:-testjob.yaml}

if [ ! -e $JOB_FILE ]; then
    echo "ERROR: LAVA job file $JOB_FILE not present."
    exit 1
fi
JOB_BASE=$(basename $JOB_FILE .yaml)

# find device_type from job file
line=$(grep ^device_type: $JOB_FILE | tr -d '[:space:]')
__device_type=${line/device_type:/}
echo "Found device_type $__device_type in LAVA job $JOB_FILE"

declare -A dt_aliases
dt_aliases=(
    [raspberrypi3-uboot]="bcm2837-rpi-3-b"
)
device_types=$__device_type
device_types+=" "
device_types+=${dt_aliases[$__device_type]}

# iterate over available labs
for lab in "${!labs[@]}"; do
  for device_type in $device_types; do
    val=${labs[$lab]}
    OFS=${IFS}
    IFS=';'
    arr=(${labs[$lab]})
    IFS=${OFS}

    url=${arr[0]}
    user=${arr[1]}

    # LAVA URL with username
    full_url=${url/:\/\//:\/\/${user}\@}

    echo -n "Checking for $device_type at $full_url... "
    line=$(lava-tool devices-list $full_url |grep $device_type | tr -d '[:space:]')
    if [ -z "$line" ]; then
	echo "not found."
	continue
    fi
    IFS='|'
    arr=($line)
    device_status=${arr[2]}
    IFS=${OFS}

    # device is only available if "idle" or "running"
    device_available=0
    if [ x"$device_status" = x"idle" ]; then
	device_available=1
    elif [ x"$device_status" = x"running" ]; then
	device_available=1;
    fi

    if [ $device_available = 0 ]; then
	echo " Not Available.  Status: $device_status"
	continue
    else
	echo " Found and available.  Status: $device_status"
    fi
    
    # Need to hack the real device-type name in the job file
    JOB_FILE_NEW="${JOB_BASE}_${lab}.yaml"
    cat $JOB_FILE | sed "s/device_type: $__device_type/device_type: $device_type/" > $JOB_FILE_NEW

    #
    # LAVA job submit, get job ID and status from lava-tool output
    #
    JOB_STATUS="${JOB_BASE}_${lab}.status"
    lava-tool submit-job --block $full_url $JOB_FILE_NEW |tee $JOB_STATUS

    IFS=':'
    line=$(grep "job id" $JOB_STATUS | tr -d '[:space:]')
    arr=($line)
    job_id=${arr[1]}
    line=$(grep "Job Status:" $JOB_STATUS | tr -d '[:space:]')
    arr=($line)
    status=${arr[1]}
    IFS=${OFS}

    echo "LAVA job $job_id completed with status: $status"

    echo "####"
    echo "#### Start: Output from LAVA job $job_id ####"
    echo "####"

    JOB_OUTPUT="${JOB_BASE}_output.yaml"
    JOB_LOG="${JOB_BASE}_output.log"
    curl -s -o $JOB_OUTPUT $full_url/scheduler/job/$job_id/log_file/plain
    cat $JOB_OUTPUT | grep '"target",' | sed -e 's#- {"dt".*"lvl".*"msg":."##g' -e 's#"}$##g' | tee $JOB_LOG

    echo "####"
    echo "#### End: Output from LAVA job $job_id ####"
    echo "####"

    # after one successful submit, we're done
    if [ x"$status" = x"Complete" ]; then
	exit 0
    else
	continue
    fi
  done
done

# if we get here, none of the labs had a successful completion
exit 1

