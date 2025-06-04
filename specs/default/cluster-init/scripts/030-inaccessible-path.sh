#!/bin/sh
set -e

# only add jetpack to path if user can actually access it because tcsh doesn't
# like inaccessible directories on the path
sed -e "s,^export PATH=,[ ! -r \\\$CYCLECLOUD_HOME/bin ] || export PATH=," -i /etc/profile.d/cyclecloud.sh

# similarly for azpbs autocomplete
if [ -e /etc/profile.d/azpbs_autocomplete.sh ]; then
    cat > /etc/profile.d/azpbs_autocomplete.sh <<EOF
if [ -r "/root/bin/azpbs" ] ; then
	which azpbs 2>/dev/null || export PATH=\$PATH:/root/bin
	eval "\$(/opt/cycle/pbspro/venv/bin/register-python-argcomplete azpbs)" || echo "Warning: Autocomplete is disabled" 1>&2
fi
EOF
fi
