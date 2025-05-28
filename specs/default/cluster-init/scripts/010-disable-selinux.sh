#!/bin/bash

set -e

# disable SELinux mostly because for some reason oddjob_request output is not
# displayed and oddjobd on scheduler node does not seem to work with it
# enabled.
# FIXME: Research the reason at some point in time to re-enable.
setenforce 0
sed -i 's/SELINUX=enforcing/SELINUX=disabled/g' /etc/selinux/config
