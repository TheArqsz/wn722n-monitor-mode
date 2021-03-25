#!/usr/bin/env bash

if [ $# -lt 1 ]; then
	echo
	echo "Usage: sudo ./run.sh <wifi_interface>"
	echo
	echo "e.g. sudo ./run.sh wlan0"
	echo
	exit 
fi

if [ "$EUID" -ne 0 ]; then
	echo "Run as root/sudo"
	exit
fi

if [ ! -d "/sys/class/net/$1" ]; then
	echo "Error: interface '$1' does not exist"
	exit
fi

if ! [ -x "$(command -v git)" ]; then
	echo "Error: git not installed!"
	echo "Install it with your package manager"
	exit
fi

tmp_dir=`mktemp -d`
echo -e "Creating tmp directory: $tmp_dir"

if [ ! -d $tmp_dir ]; then
	echo "Error: something went wrong while creating tmp directory"
	exit 
fi

user="aircrack-ng"
repo="rtl8188eus"
echo "Collecting important files from: $user/$repo"
git clone https://github.com/$user/$repo $tmp_dir

echo "Cleaning system"
rmmod r8188eu.ko 2>/dev/null
cd $tmp_dir
make uninstall 2>/dev/null
make clean 2>/dev/null

echo "Installing driver"
echo "blacklist r8188eu.ko" > /etc/modprobe.d/realtek.conf
make && make install
modprobe 8188eu

echo "Removing tmp directory"
rm -r $tmp_dir

read -p "Do you want to turn monitor mode on now? (y/N) " checkMonitor

if [[ "$checkMonitor" =~ ^(Y|y)$ ]]; then
   	echo "Turning on monitor mode"
else
   	echo "Skipping"
	echo "Reconnect your device to USB"
   	exit 0
fi

if [ ! -d "/sys/class/net/$1" ]; then
	echo "WARNING: Device disconnected"
	echo "Reconnect your device to USB"
	echo "and execute following commands:"
	echo "	ifconfig $1 down"
	echo "	iwconfig $1 mode monitor"
	echo "	ifconfig $1 up"
	exit
fi

echo "Setting up monitor mode"
ifconfig $1 down
status=$(iwconfig $1 mode monitor)
if [[ ! "$status" == "" ]]; then
	echo "Error: cannot set up monitor mode for $1"
fi
ifconfig $1 up
