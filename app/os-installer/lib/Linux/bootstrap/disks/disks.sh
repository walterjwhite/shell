_disk_serial() {
	smartctl -i $1 | grep 'Serial Number' | awk {'print$3'}
}

_init_disk_layout() {
	sgdisk -Z ${_CONF_OS_INSTALLER_DISK_DEV}

	sgdisk -g ${_CONF_OS_INSTALLER_DISK_DEV}

	sgdisk -n 1:0:+1G -t 1:ef00 ${_CONF_OS_INSTALLER_DISK_DEV}
	sgdisk -n 2:+1G:0 -t 1:8300 ${_CONF_OS_INSTALLER_DISK_DEV}

	partprobe

	_setup_disks_efi

	mkfs.vfat -F 32 ${_CONF_OS_INSTALLER_DISK_DEV_EFI_PARTITION}
}

_setup_disks_efi() {
	_CONF_OS_INSTALLER_DISK_DEV_BOOT_PARTITION_ID=1
	_CONF_OS_INSTALLER_DISK_DEV_EFI_PARTITION=${_CONF_OS_INSTALLER_DISK_DEV}${_CONF_OS_INSTALLER_DISK_DEV_PARTITION_PREFIX}$_CONF_OS_INSTALLER_DISK_DEV_BOOT_PARTITION_ID
}

_disk_partition_get_uuid() {
	lsblk -o name,uuid $1 | sed 1d | head -1 | awk {'print$2'}
}

_backup_disk_layout() {
	sgdisk -b $_CONF_OS_INSTALLER_DISK_DEV_NAME/sgdisk.part ${_CONF_OS_INSTALLER_DISK_DEV}

}
