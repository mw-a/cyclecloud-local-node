#!/bin/sh
set -e

# screen is in epel nowadays
rpm -q epel-release >/dev/null 2>&1 || dnf install -y epel-release

pkgs="tmux screen vim"
pkgcount=$(echo $pkgs | wc -w)
[ "$(rpm -qa $pkgs | wc -l )" -eq $pkgcount ] || dnf install -y $pkgs
