#!/bin/bash

NORMAL=$(tput sgr0)

## Foreground colors
FG_RED=$(tput setaf 1)
FG_GREEN=$(tput setaf 2; tput bold)
FG_YELLOW=$(tput setaf 3)
FG_BLUE=$(tput setaf 4)
FG_MAGENTA=$(tput setaf 5)
FG_CYAN=$(tput setaf 6)

## Background colors
BG_BLUE=$(tput setab 4)
DEBUG=true

function red() {
    echo -e "$FG_RED$*$NORMAL"
}

function green() {
    echo -e "$FG_GREEN$*$NORMAL"
}

function yellow() {
    echo -e "$FG_YELLOW$*$NORMAL"
}

function debug() { [ "$DEBUG" ] && echo -e "$BG_BLUE$FG_YELLOW>>> $*$NORMAL"; }

# Detect OS "Ubuntu", "LinuxMint" e.t.c.
OS=$(lsb_release -si)
# Detect architecture "32" or "64"
ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
# Detect release version
VER=$(lsb_release -sr)

X64=false
if [[ ${ARCH} == "64" ]]; then
	X64=true
fi

function favourites() {
	echo 'Installing favourite packages. Root required:'

	if [[ ${OS} == "Ubuntu" }]]; then
		sudo apt-get install -y synaptic openssh-server filezilla chromium-browser deluge geeqie inkscape ssh git ia32-libs whois rar nautilus-dropbox ubuntu-restricted-extras nautilus-open-terminal
	elif [[ ${OS} == "LinuxMint" ]]; then
		sudo apt-get install -y synaptic openssh-server filezilla chromium-browser deluge geeqie inkscape ssh git ia32-libs whois rar nemo-dropbox 
	fi

	has_nvidia=`lspci | grep NVIDIA`
	if [[ has_nvidia != "" ]]; then
		sudo apt-get install -y bumblebee-nvidia primus
	fi
	main
}


function filebot() {
	echo 'Installing Filebot. Root required:'
	#sudo add-apt-repository ppa:webupd8team/sublime-text-2
	#sudo apt-get update
	#sudo apt-get install sublime-text
	main
}


function sublime2() {
	echo 'Installing Sublime Text 2. Root required:'
	sudo add-apt-repository ppa:webupd8team/sublime-text-2
	sudo apt-get update
	sudo apt-get install sublime-text
	clear && main
}

function java() {
	echo 'Installing Oracle Java. Root required:'
	sudo add-apt-repository ppa:webupd8team/java
	sudo apt-get update
	sudo apt-get install oracle-java7-installer oracle-jdk7-installer oracle-java7-set-default
	# This might have been done by the set-defaults, but rather safe than sorry
	sudo update-java-alternatives -s java-7-oracle
	clear && main
}

function bitcoin() {
	echo 'Installing Bitcoin. Root required:'
	sudo add-apt-repository ppa:bitcoin/bitcoin
	sudo apt-get update
	sudo apt-get install bitcoin-qt
	clear && main
}

function teamviewer() {
	PACKAGE="teamviewer"
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $PACKAGE|grep "install ok installed")
	if [[ "" == "$PKG_OK" ]]; then
		teamviewer-install
	else
		sudo apt-get remove --purge $PACKAGE
	fi
}

function teamviewer-install() {
	
	# get the right package
	PACKAGE="teamviewer_linux.deb"
	if [ $X64 ]; then
		PACKAGE="teamviewer_linux_x64.deb"
	fi
	
	wget http://download.teamviewer.com/download/$PACKAGE
	sudo dpkg -i $PACKAGE
	sudo apt-get -f install
	rm $PACKAGE
	main
}

function eclipse() {
	echo 'Downloading Eclipse...'
	# get the right package
	
	PACKAGE="eclipse-standard-kepler-SR1-linux-gtk.tar.gz"
	if [ $X64 ]; then
		PACKAGE="eclipse-standard-kepler-SR1-linux-gtk-x86_64.tar.gz"
	fi
	
	wget http://ftp.fau.de/eclipse/technology/epp/downloads/release/kepler/SR1/$PACKAGE
	echo 'Extracting Eclipse...'
	tar xvzf $PACKAGE

	echo 'Moving Eclipse to /opt directory...'
	sudo mv eclipse /opt

	echo 'Creating .desktop file and icon'
    touch eclipse.desktop
	
	echo "[Desktop Entry]
	Type=Application
	Name=Eclipse
	Comment=Eclipse Integrated Development Environment
	Icon=eclipse
	Exec=eclipse
	Terminal=false
	Categories=Development;IDE;Java;" >> eclipse.desktop

    sudo mv -f eclipse.desktop /usr/share/applications/
	sudo cp /opt/eclipse/icon.xpm /usr/share/pixmaps/eclipse.xpm

    echo 'Creating symbolic link... Root required:'
    sudo ln -sf /opt/eclipse/eclipse /usr/bin/eclipse

    echo 'Cleaning up...'
    rm eclipse.tar.gz

	main
}

function android-sdk() {
	
	if [ $X64 ]; then
		echo 'Installing 32bit libs. Root required:'
		sudo apt-get install -y ia32-libs
	fi
	
	echo 'Downloading Android SDK...'
	wget http://dl.google.com/android/android-sdk_r22.6.2-linux.tgz
	
	echo 'Extracting Android SDK...'
	tar xvzf android-sdk_r22.3-linux.tgz
	
	echo 'Removing tar file...'
	rm android-sdk_r22.3-linux.tgz

	echo 'Moving Android SDK to home folder...'
	mv android-sdk-linux $HOME

	echo 'Adding Android SDK to PATH'
	echo 'if [ -d "$HOME/android-sdk-linux/tools" ] ; then
	    PATH="$HOME/android-sdk-linux/tools:$PATH"
	fi

	if [ -d "$HOME/android-sdk-linux/platform-tools" ] ; then
	    PATH="$HOME/android-sdk-linux/platform-tools:$PATH"
	fi' >> $HOME/.profile
	
	echo 'Preparing for rules for hardware devices'
	RULES='/etc/udev/rules.d/51-android.rules'
	sudo touch $RULES
	
	# Acer, ASUS, Google, HTC, Huawei, LG,Motorola, Samsung, Sony
	echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0502", MODE="0666", GROUP="plugdev"' | sudo tee -a $RULES
	echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="18d1", MODE="0666", GROUP="plugdev"' | sudo tee -a $RULES
	echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="0bb4", MODE="0666", GROUP="plugdev"' | sudo tee -a $RULES
	echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="12d1", MODE="0666", GROUP="plugdev"' | sudo tee -a $RULES
	echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="1004", MODE="0666", GROUP="plugdev"' | sudo tee -a $RULES
	echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="22b8", MODE="0666", GROUP="plugdev"' | sudo tee -a $RULES
	echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="plugdev"' | sudo tee -a $RULES
	echo 'SUBSYSTEM=="usb", ATTR{idVendor}=="054c", MODE="0666", GROUP="plugdev"' | sudo tee -a $RULES

	sudo chmod a+r $RULES
	
	main

}

function sysupgrade() {
	read -p 'Proceed with system upgrade? [y/n] : ' REPLY
	case $REPLY in
	# Positive action
	[Yy]* )
	    echo 'Performing system upgrade. Root required:'
	    sudo apt-get dist-upgrade -y
	    main ;;
	# Negative action
	[Nn]* )
	    main ;;
	# Error
	* )
	    clear && echo 'Sorry, try again.'
	    sysupgrade;;
	esac
}

function main() {
	clear
	echo 'Welcome to -anything deb- installation'
	echo ''
	echo '1. Perform system upgrade'
	echo '2. Install all standard applications'
	echo '3. Install Sublime Text 2'
	echo '4. Install Oracle Java'
	echo '5. Install Bitcoin Client'
	echo '6. Install Team Viewer'
	echo '7. Install Eclipse'
	echo '8. Install Android SDK'
	echo '9. Cleanup the system'
	echo 'q. Quit?'
	echo ''
	read -p 'What would you like to do? (Enter your choice) : ' REPLY
	case $REPLY in
		1) clear && sysupgrade;;
		2) clear && favourites;;
		3) clear && sublime2;;
		4) clear && java;;
		5) clear && bitcoin;;
		6) clear && teamviewer;;
		7) clear && eclipse;;
		8) clear && android-sdk;;
		9) clear && cleanup;;
		[Qq]* ) clear && exit 0;;
		* ) clear && echo 'Not an option, try again.' && main;;
	esac
	
}

## Add PPA's and update
function updatepackagelist() {
	echo 'Updating packagelist and updating old packages. Root required:'
	sudo apt-get update
	main
}

main
