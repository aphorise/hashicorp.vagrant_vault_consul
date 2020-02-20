#!/bin/bash
export DEBIAN_FRONTEND=noninteractive ;
set -eu ; # abort this script when a command fails or an unset variable is used.
#set -x ; # echo all the executed commands.

# Repair "==> default: stdin: is not a tty" message
sudo ex +"%s@DPkg@//DPkg" -cwq /etc/apt/apt.conf.d/70debconf
sudo dpkg-reconfigure debconf -f noninteractive -p critical

export LANGUAGE=en_US.UTF-8 ;
export LANG=en_US.UTF-8 ;
export LC_ALL=en_US.UTF-8 ;
locale-gen en_US.UTF-8 2>&1>/dev/null && dpkg-reconfigure locales 2>&1>/dev/null;

sudo apt-get install -yq policykit-1 unzip curl htop screen jq ;
