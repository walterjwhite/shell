_disk_serial() {
  smartctl -i $1 | grep 'Serial Number' | awk {'print$3'}
}

_init_disk_layout() {
  sgdisk -Z ${conf_os_installer_disk_dev}

  sgdisk -g ${conf_os_installer_disk_dev}

  sgdisk -n 1:0:+1G -t 1:ef00 ${conf_os_installer_disk_dev}
  sgdisk -n 2:+1G:0 -t 1:8300 ${conf_os_installer_disk_dev}

  partprobe

  mkfs.vfat -F 32 ${conf_os_installer_disk_dev_efi_partition}
}

_setup_disks_efi() {
  conf_os_installer_disk_dev_boot_partition_id=1
  conf_os_installer_disk_dev_efi_partition=${conf_os_installer_disk_dev}${conf_os_installer_disk_dev_partition_prefix}$conf_os_installer_disk_dev_boot_partition_id
}

_disk_partition_get_uuid() {
  lsblk -no uuid -d $1
}

_backup_disk_layout() {
  sgdisk -b $conf_os_installer_disk_dev_name/sgdisk.part ${conf_os_installer_disk_dev}

}
