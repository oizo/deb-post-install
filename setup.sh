#!/bin/bash
#
# This scripts gets all other scripts needed for installing my base debian system
#

function die () {
	echo >&2 "$@"
	exit 1
}

function download() {
	url="https://raw.githubusercontent.com/oizo/deb-post-install/master/$1"
	success=$(wget -q $url)
	if [[ success -ne 0 ]]; then
		die "Failed to get $url, exiting..."
	fi
}

cd $HOME
bin_dir="bin"
if [[ ! -e ${bin_dir} ]]; then
	mkdir -p ${bin_dir}
elif [[ ! -d ${bin_dir} ]]; then
	die "${bin_dir} is not a directory."
fi

cd ${bin_dir}

declare -a scripts=('post-install-deb.sh' 'post-install-eee.sh' 'sshmount.sh');

echo "Downloading: ${scripts[@]}"

for script in "${scripts[@]}"; do
	download $script
done

for script in "${scripts[@]}"; do
	sudo chmod a+x $script
done

PATH="$HOME/${bin_dir}:$PATH"

echo "Done, scripts are located in $HOME/$bin_dir"