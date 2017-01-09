# (c) 2016 Jan-Simon Moeller dl9pf(at)gmx.de
# License GPLv2

################################################################################
## Run SHORT CI test
################################################################################

# test currently only for porter, rest WIP
echo "## ${MACHINE} ##"


echo "default keyring config"

mkdir -p ~/.local/share/python_keyring/

cat <<EOF >  ~/.local/share/python_keyring/keyringrc.cfg
[backend]
default-keyring=keyring.backends.file.PlaintextKeyring
EOF

cat <<EOF > ~/.local/token
$AGLLAVATOKEN
EOF

lava-tool auth-add --token-file ~/.local/token https://agl-jenkins-user@porter.automotivelinux.org

cat ~/.local/token

#rm ~/.local/token

# setup 