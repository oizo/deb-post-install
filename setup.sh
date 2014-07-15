#!/bin/bash
#
# This scripts gets all other scripts needed for installing my base debian system
#

die () { echo >&2 "$@"; exit 1 }

cd $HOME
bin_dir="bin"
if [[ ! -e ${bin_dir} ]]; then
	mkdir -p ${bin_dir}
	cd ${bin_dir}
elif [[ ! -d ${bin_dir} ]]; then
	die "${bin_dir} is not a directory."
fi

echo "Downloading scripts..."

wget https://github.com/oizo/deb-post-install/blob/master/post-install-deb.sh
wget https://github.com/oizo/deb-post-install/blob/master/post-install-eee.sh
wget https://github.com/oizo/deb-post-install/blob/master/sshmount.sh

echo "Done"

