#!/bin/bash

. /etc/os-release

pkgs="libnsl"

case "$VERSION_ID" in
	8.*)
		pkgs="$pkgs lsb python2"
		;;
esac

pkgcount=$(echo $pkgs | wc -w)
[ "$(rpm -qa $pkgs | wc -l )" -eq $pkgcount ] || dnf install -y $pkgs
