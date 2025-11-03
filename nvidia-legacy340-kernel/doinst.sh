
chroot . /sbin/depmod -a @KERNEL@ 2>/dev/null

/usr/sbin/nvidia-prepare-boot
