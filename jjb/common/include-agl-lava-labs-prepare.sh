# (c) 2017 Kevin Hilman <khilman@baylibre.com>
# License GPLv2

#
# Setup LAVA API authentication tokens for various LAVA labs
#
# Uses user/token pairs from Jenkins secrets
#
declare -A labs
labs=(
    [agl]="https://lava.automotivelinux.org/;$LAB_AGL_USER;$LAB_AGL_TOKEN"
    [baylibre]="http://lava.baylibre.com:10080/;$LAB_BAYLIBRE_USER;$LAB_BAYLIBRE_TOKEN"
#    [baylibre_seattle]="http://lava.ished.com/;$LAB_BAYLIBRE_SEATTLE_USER;$LAB_BAYLIBRE_SEATTLE_TOKEN"
    )

#
# Ensure python_keyring is set to plaintext.  Required for
# non-interactive use
#
echo "default keyring config"
mkdir -p ~/.local/share/python_keyring/
cat <<EOF >  ~/.local/share/python_keyring/keyringrc.cfg
[backend]
default-keyring=keyring.backends.file.PlaintextKeyring
EOF

for lab in "${!labs[@]}"; do
    val=${labs[$lab]}
    OFS=${IFS}
    IFS=';'
    arr=(${labs[$lab]})
    IFS=${OFS}

    url=${arr[0]}
    user=${arr[1]}
    token=${arr[2]}
    token_file=$HOME/.local/lab-$lab-token

    if [ -z ${user} ]; then
	echo "WARNING: Lab ${lab}: missing user. Ignoring."
	continue
    fi
    if [ -z ${token} ]; then
	echo "WARNING: Lab ${lab}: missing token. Ignoring."
	continue
    fi

    # LAVA URL with username
    full_url=${url/:\/\//:\/\/${user}\@}
    echo "LAVA auth-add for lab: $lab, URL: $full_url"
    
    # LAVA auth using token
    echo ${token} > $token_file
    lava-tool auth-add --token $token_file $full_url
    if [ $? != 0 ]; then
	echo "ERROR: Lab ${lab}: lava-tool auth-add failed."
    fi
    rm -f $token_file
done
