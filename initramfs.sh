#!/bin/bash

rm -r /tmp/initramfs/
mkdir -p /tmp/initramfs/

mkdir -p /tmp/initramfs/{bin,etc,dev,lib,proc,sbin,sys,usr/lib,new_root}

cp ramfs/wpa_supplicant.conf /tmp/initramfs/etc
cp ramfs/init /tmp/initramfs/
chmod +x /tmp/initramfs/init

# Required programs
cp /usr/armv6j-hardfloat-linux-gnueabi/{bin/busybox,usr/sbin/{iw,wpa_supplicant},sbin/dhcpcd} /tmp/initramfs/bin/
ln -s busybox /tmp/initramfs/bin/sh

# Required shared libraries
cp /usr/armv6j-hardfloat-linux-gnueabi/lib/{libresolv*,libnss_{dns,files}*,ld-*,libc-*,libc.so*,libpthread*,librt*,libdl*,libz.so*} /tmp/initramfs/lib
cp /usr/armv6j-hardfloat-linux-gnueabi/usr/lib/{libnl-*,libtommath*,libssl*,libcrypto.so*} /tmp/initramfs/usr/lib/

# Required Linux modules. Replace rtl8192cu with your Wifi adapter.
mods="$(./modules.sh rtl8192cu ipv6 ccm ctr)"
cd /usr/armv6j-hardfloat-linux-gnueabi/
for i in $mods; do
	find lib/modules/4.9.80+/ -type f -name "${i}.ko" -exec cp --parents \{\} /tmp/initramfs/ \;
done

echo "$mods" | sed 's/^/modprobe /' | sed '1i#!/bin/sh' > /tmp/initramfs/etc/modules.sh
chmod +x /tmp/initramfs/etc/modules.sh

# Required firmware. Replace 8192cu with your required firmware.
find lib/firmware -type f -name "*8192cu*" -exec cp --parents \{\} /tmp/initramfs/ \;

#dhcpcd
find usr/share/dhcpcd/ lib/dhcpcd/ -type f -exec cp --parents \{\} /tmp/initramfs/ \;
cp etc/dhcpcd.conf /tmp/initramfs/etc
mkdir /tmp/initramfs/var/lib/dhcpcd -p

cd /tmp/initramfs
find . -print0 | cpio --null -ov --format=newc | gzip -9 > /usr/armv6j-hardfloat-linux-gnueabi/boot/init.cpio.gz
