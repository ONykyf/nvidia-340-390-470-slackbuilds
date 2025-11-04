
chroot . /sbin/depmod -a @KERNEL@ 2>/dev/null

KERNELVER=@KERNEL@ /usr/sbin/nvidia-prepare-boot
