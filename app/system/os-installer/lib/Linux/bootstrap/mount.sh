lib install/emerge.sh

_bootstrap_mounts() {
  APP_PLATFORM_ROOT=$conf_os_installer_mountpoint _emerge_portage_setup_chroot_mounts
}

_bootstrap_mount_efi() {
  log_detail "mounting EFI partition @ $conf_os_installer_mountpoint"

  mkdir -p $conf_os_installer_mountpoint/boot $conf_os_installer_mountpoint/efi
  mount ${conf_os_installer_disk_dev_efi_partition} $conf_os_installer_mountpoint/boot && exit_defer umount $conf_os_installer_mountpoint/boot
  mount ${conf_os_installer_disk_dev_efi_partition} $conf_os_installer_mountpoint/efi && exit_defer umount $conf_os_installer_mountpoint/efi
}

_bootstrap_write_fstab() {
  local esp_uuid=$(_disk_partition_get_uuid $conf_os_installer_disk_dev_efi_partition)

  printf '# <fs>      <mountpoint>  <type>    <opts>    <dump> <pass>\n' >>$conf_os_installer_mountpoint/etc/fstab
  printf '# ESP\n' >>$conf_os_installer_mountpoint/etc/fstab

  case $conf_os_installer_init in
  systemd)
    printf 'UUID=%s /efi vfat defaults,noatime,uid=0,gid=0,umask=0077,x-systemd.automount,x-systemd.idle-timeout=600 0 2\n' $esp_uuid >>$conf_os_installer_mountpoint/etc/fstab
    ;;
  esac
}
