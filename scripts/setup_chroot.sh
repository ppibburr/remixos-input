mount /dev/block/sda8 /sdcard/t
mount -o bind /dev /sdcard/t/dev
mount -o bind /dev/pts /sdcard/t/dev/pts
mount -t sysfs /sys /sdcard/t/sys
mount -t proc /proc /sdcard/t/proc

setprop adb.tcpip.port 5555
stop adbd
start adbd

chroot /sdcard/t /home/ppibburr/remixos-input/scripts/init
