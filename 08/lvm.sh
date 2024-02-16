yum -y install lvm2 rsync
parted /dev/sdb mklabel msdos
parted /dev/sdb mkpart primary ext4 0% 10%
parted /dev/sdb mkpart primary xfs 10% 100%
parted /dev/sdb set 1 boot on
parted /dev/sdb set 2 lvm on
pvcreate /dev/sdb2
vgcreate VolGroup00 /dev/sdb2
lvcreate -n root -l 100%FREE VolGroup00
mkfs.ext4 /dev/sdb1
mkfs.xfs /dev/VolGroup00/root 
mkdir /newroot
mount /dev/VolGroup00/root /newroot/
mkdir /newroot/boot
mount /dev/sdb1 /newroot/boot/
mkdir /oldroot
mount -o bind / /oldroot
rsync -ax /oldroot/ /newroot/
echo "$(blkid | grep sdb1 | cut -d ' ' -f 2) /boot     ext4    defaults        1 2" >> /newroot/etc/fstab 
sed -r -i 's/(^UUID=.*-.*-.*-.*-.* \/                       xfs     defaults        0 0)/#\1/g' /newroot/etc/fstab 
echo "/dev/mapper/VolGroup00-root                   /         xfs     defaults        0 0" >> /newroot/etc/fstab
sed -r -i 's/(GRUB_CMDLINE_LINUX="no_timer_check) console=tty0 (console=ttyS0,115200n8 net.ifnames=0 biosdevname=0 elevator=noop crashkernel=auto)"/\1 \2 console=tty0 rd.lvm.lv=VolGroup00\/root"/g' /newroot/etc/default/grub 
mount -o bind /dev /newroot/dev
mount -o bind /sys /newroot/sys
mount -o bind /proc /newroot/proc
chroot /newroot/ /bin/bash <<"EOT"
  grub2-mkconfig -o /boot/grub2/grub.cfg 
  dracut -f -v /boot/initramfs-$(uname -r).img 
  grub2-install --recheck /dev/sdb
  touch /.autorelabel
EOT
shutdown -h now