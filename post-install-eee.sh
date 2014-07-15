#!/bin/bash

function deluge() {

	echo 'Installing deluged and web-client'
	sudo apt-get install deluged deluge-web
	
	echo 'Creating new user and group - deluge"'
	sudo adduser --system --group --home /var/lib/deluge deluge
	
	echo 'Adding current user to the group'
	sudo adduser $USER deluge
	
	echo 'Creating deluged init script'
	echo "# deluged - Deluge daemon
#
# The daemon component of Deluge BitTorrent client. Deluge UI clients
# connect to this daemon via DelugeRPC protocol.

description \"Deluge daemon\"
author \"Deluge Team\"

start on filesystem and static-network-up
stop on runlevel [016]

respawn
respawn limit 5 30

env uid=$USER
env gid=deluge
env umask=007

exec start-stop-daemon -S -c \$uid:\$gid -k \$umask -x /usr/bin/deluged -- -d" >> deluged.conf

	sudo mv deluged.conf /etc/init/

	echo 'Creating deluge-web init script'
	echo "# deluge-web - Deluge Web UI
#
# The Web UI component of Deluge BitTorrent client, connects to deluged and
# provides a web application interface for users. Default url: http://localhost:8112

description \"Deluge Web UI\"
author \"Deluge Team\"

start on started deluged
stop on stopping deluged

respawn
respawn limit 5 30

env uid=$USER
env gid=deluge
env umask=027

exec start-stop-daemon -S -c \$uid:\$gid -k \$umask -x /usr/bin/deluge-web" >> deluge-web.conf
	sudo mv deluge-web.conf /etc/init/

	# Prepare directories for download
	mkdir ~/Downloads
	cd ~/Downloads
	mkdir dl_temp
	mkdir dl_done
	mkdir dl_torrent
	mkdir dl_auto_add

}


function settings() {

	echo 'Prevent sleep when closing laptop lid'
	echo 'HandleLidSwitch=ignore' | sudo tee -a /etc/systemd/logind.conf
	
	echo 'Installing nice to have extras'
	sudo apt-get install acpi htop
	
	echo 'Do we need a webserver? - Front facing message?'
	
}

deluge
settings

clear
echo 'Installation done'

