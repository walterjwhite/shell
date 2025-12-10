_init_disk_encryption_get_device() {
	OS_INSTALLER_DISK_DEV_ENCRYPTED=${_CONF_OS_INSTALLER_DISK_DEV}p2
	OS_INSTALLER_DISK_ZFS_DEV=${_CONF_OS_INSTALLER_DISK_DEV}p2.eli
}

_init_disk_encryption() {
	_DETAIL "Setting up geli on $_CONF_OS_INSTALLER_DISK_DEV"
	printf '%s' "$OS_INSTALLER_DISK_PASSPHRASE" | geli init -g -b -J - -l 256 -s 4096 $OS_INSTALLER_DISK_DEV_ENCRYPTED
}

_open_disk_encryption() {
	printf '%s' "$OS_INSTALLER_DISK_PASSPHRASE" | geli attach -j - $OS_INSTALLER_DISK_DEV_ENCRYPTED
}

_close_encrypted_disks() {
	geli detach $OS_INSTALLER_DISK_ZFS_DEV
}

_backup_disk_encryption_headers() {
	geli backup $OS_INSTALLER_DISK_DEV_ENCRYPTED $_CONF_OS_INSTALLER_DISK_DEV_NAME/geli
}
