_init_chroot() {
  pacman-key --init
  pacman-key --populate archlinux cachyos

  pacstrap -K $conf_os_installer_mountpoint base base-devel linux-cachyos linux-cachyos-headers cachyos-keyring cachyos-mirrorlist cachyos-hooks zfs-utils networkmanager sudo

  chroot $conf_os_installer_mountpoint bootctl install

  cat <<EOF >/mnt/boot/loader/loader.conf
default cachyos.conf
timeout 4
console-mode max
editor no
EOF

  cat <<EOF >/mnt/boot/loader/entries/cachyos.conf
title   CachyOS (CLI Minimal ZFS)
linux   /vmlinuz-linux-cachyos
initrd  /initramfs-linux-cachyos.img
options zfs=$conf_cachyos_installer_zpool_name/ROOT/default rw
EOF
}
