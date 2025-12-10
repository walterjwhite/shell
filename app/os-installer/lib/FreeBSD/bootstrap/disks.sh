_disk_serial() {
	geom disk list $1 | grep ident | awk {'print$2'}
}

_init_disk_layout() {
	_DETAIL "Partitioning disk: $_CONF_OS_INSTALLER_DISK_DEV"


	gpart destroy -F ${_CONF_OS_INSTALLER_DISK_DEV}
	zpool labelclear -f ${_CONF_OS_INSTALLER_DISK_DEV}

	gpart create -s gpt ${_CONF_OS_INSTALLER_DISK_DEV}
	gpart add -a 4k -l efiboot0 -t efi -s 260M ${_CONF_OS_INSTALLER_DISK_DEV}

	FREEBSD_ESP_DEVICE=/dev/gpt/efiboot0
	newfs_msdos -c 1 -F 32 $FREEBSD_ESP_DEVICE

	gpart add -a 1m -l zfs0 -t freebsd-zfs ${_CONF_OS_INSTALLER_DISK_DEV}
}

_backup_disk_layout() {
	gpart backup $_CONF_OS_INSTALLER_DISK_DEV >$_CONF_OS_INSTALLER_DISK_DEV_NAME/gpart

}
