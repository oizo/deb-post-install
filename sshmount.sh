#!/bin/bash

# Default config
SSH_USER=""
SSH_HOST=""
SSH_PORT=""
LOCAL_FOLDER=""
REMOTE_FOLDER=""

die () {
	echo >&2 "$@"
	exit 1
}

goodbye () {
	echo >&2 "$@"
	exit 0
}

usage() {
	die "Usage: `basename $0` <1000h | diskstation | workstation>"
}

1000h() {
	SSH_USER=oizo
	SSH_HOST=home.dannyhvam.dk
	SSH_PORT=22
	LOCAL_FOLDER=1000h
	REMOTE_FOLDER=/home/oizo/
}

diskstation() {
	SSH_USER=oizo
	SSH_HOST=home.dannyhvam.dk
	SSH_PORT=5022
	LOCAL_FOLDER=DiskStation
	REMOTE_FOLDER=/
}

workstation() {
	SSH_USER=oizo
	SSH_HOST=home.dannyhvam.dk
	SSH_PORT=2022
	LOCAL_FOLDER=WorkStation
	REMOTE_FOLDER=/
}

ssh_unmount() {
	read -p "$LOCAL_FOLDER already mounted, do you wish to un-mount? [y/n] : " REPLY
	case $REPLY in

	[Yy]* )
	    sudo umount $HOME/$LOCAL_FOLDER
		if [[ $? -eq 0 ]]; then
			goodbye "$LOCAL_FOLDER unmounted"
		else
			die "Unmounting $LOCAL_FOLDER failed"
		fi;;

	[Nn]* )
		goodbye "done...";;

	* )
		clear && echo "Sorry, try again." && ssh_unmount;;
	esac
}

ssh_mount() {
	echo "Mounting $LOCAL_FOLDER, this may take a minute..."
	sshfs $SSH_USER@$SSH_HOST:$REMOTE_FOLDER $LOCAL_FOLDER -p $SSH_PORT
	if [[ $? -eq 0 ]]; then
		goodbye "$LOCAL_FOLDER successfully mounted in $HOME/$LOCAL_FOLDER"
	else
		die "Mounting $LOCAL_FOLDER failed"
	fi
}

# Checking if sshfs is installed
check_sshfs() {
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' sshfs|grep "install ok installed")
	if [[ "" == "$PKG_OK" ]]; then
		echo "sshfs not detected. Installing sshfs... (enter root password)"
		sudo apt-get --force-yes --yes install sshfs
	fi
}

# Checking if user is in fuse
check_fuse() {
	INFUSE=`groups $USER | grep fuse`
	if [[ "" == $INFUSE ]]; then
	    echo "$USER not in fuse. Adding user... (enter root password)"
		sudo gpasswd -a $USER fuse
	fi
}

# Creating LOCAL_FOLDER if not exists
check_folder() {
	if [[ ! -e $LOCAL_FOLDER ]]; then
		mkdir -p "$LOCAL_FOLDER"
	elif [[ ! -d $LOCAL_FOLDER ]]; then
		die "$LOCAL_FOLDER is not a directory. Change \$LOCAL_FOLDER in `basename $0`, or delete $HOME/$LOCAL_FOLDER"
	fi
}

setup_ssh_vars() {
	if [[ "$1" == "1000h"  ]]; then
		1000h
	elif [[ "$1" == "diskstation"  ]]; then
		diskstation
	elif [[ "$1" == "workstation"  ]]; then
		workstation
	else
		usage
	fi
}

# Check if drive is allready mounted, before mounting
check_mount_state() {
	is_mounted=`mount | grep $LOCAL_FOLDER`
	if [[ "" == "${is_mounted}" ]]; then
		ssh_mount && exit 0
	else
		ssh_unmount
	fi
}

cd $HOME
setup_ssh_vars "$1"
check_sshfs
check_fuse
check_folder
check_mount_state