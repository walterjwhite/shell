_disk_serial() {
  geom disk list $1 | grep ident | awk {'print$2'}
}

_init_disk_layout() {
  log_detail "partitioning disk: $conf_os_installer_disk_dev"


  gpart destroy -F ${conf_os_installer_disk_dev}
  zpool labelclear -f ${conf_os_installer_disk_dev}

  gpart create -s gpt ${conf_os_installer_disk_dev}
  gpart add -a 4k -l efiboot0 -t efi -s 260M ${conf_os_installer_disk_dev}

  newfs_msdos -c 1 -F 32 $conf_os_installer_disk_dev_efi_partition

  gpart add -a 1m -l zfs0 -t freebsd-zfs ${conf_os_installer_disk_dev}
}

_setup_disks_efi() {
  conf_os_installer_disk_dev_partition_prefix=p
  conf_os_installer_disk_dev_boot_partition_id=1
  conf_os_installer_disk_dev_efi_partition=${conf_os_installer_disk_dev}${conf_os_installer_disk_dev_partition_prefix}$conf_os_installer_disk_dev_boot_partition_id
}

_backup_disk_layout() {
  gpart backup $conf_os_installer_disk_dev >$conf_os_installer_disk_dev_name/gpart

}
