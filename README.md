# Script for monitor mode in TPLink wn722n v2/v3 network adapter

## Prerequisites

All you need is:

- git
- iwconfig
- ifconfig (`net-tools`)
- access to `root`/`sudo`

## Install

All you have to do is:

- connect your adapter to USB (or make sure it is connected to virtual machine)
- execute commands:
```console
git clone https://github.com/TheArqsz/wn722n-monitor-mode
cd wn722n-monitor-mode
chmod +x run.sh
./run.sh <network interface>
```