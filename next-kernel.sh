#!/bin/bash

cd /linux/linux-mainline/ 
git fetch --all
KERNELVERSION=$(git tag --sort creatordate | tail -1)
echo "Compiling Linux Kernel $KERNELVERSION"
git reset --hard $KERNELVERSION

yes "" | make -j16
sudo make modules_install install -j16

dunstify "Kernel $KERNELVERSION is ready" "Sysrq + REISUB to reboot"
