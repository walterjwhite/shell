_bootstrap_mounts() {
  mkdir $conf_os_installer_mountpoint/dev 2>/dev/null
  mount -t devfs devfs $conf_os_installer_mountpoint/dev && exit_defer umount $conf_os_installer_mountpoint/dev

  _bootstrap_mount_swap
}

_bootstrap_mount_efi() {
  mkdir -p $conf_os_installer_mountpoint/boot/efi
  mount_msdosfs $conf_os_installer_disk_dev_efi_partition $conf_os_installer_mountpoint/boot/efi && exit_defer umount $conf_os_installer_mountpoint/boot/efi
}

_bootstrap_write_fstab() {
  mkdir -p $conf_os_installer_mountpoint/etc
  printf '# efi partition\n' >$conf_os_installer_mountpoint/etc/fstab
  printf '#%s /boot/efi msdosfs rw 2 2\n' $conf_os_installer_disk_dev_efi_partition >>$conf_os_installer_mountpoint/etc/fstab

  printf 'tmpfs /tmp tmpfs rw,mode=1777,size=256M 0 0\n' >>$conf_os_installer_mountpoint/etc/fstab
  printf 'tmpfs /run tmpfs rw,mode=1777,size=64M 0 0\n' >>$conf_os_installer_mountpoint/etc/fstab
}

_bootstrap_mount_swap() {
  local swap_device=$(grep swap $conf_os_installer_mountpoint/etc/fstab 2>/dev/null | awk {'print$1'})
  [ -n "$swap_device" ] && {
    log_detail "activating swap: $swap_device"
    swapon $swap_device
    return 0
  }

  log_warn "no swap detected"
}

