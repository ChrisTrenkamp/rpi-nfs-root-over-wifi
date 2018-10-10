#!/bin/bash
umount /dev/sdc1
mkfs.vfat /dev/sdc1
mount /dev/sdc1 /mnt
cp -r kernel/firmware/boot/* boot/* /usr/armv7a-hardfloat-linux-gnueabi/boot/{rpi-kernel,init.cpio.gz} /mnt
umount /dev/sdc1
