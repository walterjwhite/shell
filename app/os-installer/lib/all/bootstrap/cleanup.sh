_cleanup_prior_installation() {
	_cleanup_processes

	_cleanup_mounts
	_cleanup_zfs
	_close_encrypted_disks
}

_cleanup_mounts() {
	mount | grep -qm1 " on $_CONF_OS_INSTALLER_MOUNTPOINT" || return 0

	umount -f$_OS_INSTALLER_UMOUNT_OPTIONS $(mount | grep " on $_CONF_OS_INSTALLER_MOUNTPOINT" | awk {'print$3'} | sort -r)
	mount | grep -qm1 $_CONF_OS_INSTALLER_MOUNTPOINT && _ERROR "Unable to unmount all volumes, please check"

	return 0
}

_cleanup_zfs() {
	[ -z "$OS_INSTALLER_ZFS_POOL_NAME" ] && return 1

	zpool list -H $OS_INSTALLER_ZFS_POOL_NAME >/dev/null 2>&1 || {
		_WARN "no need to export $OS_INSTALLER_ZFS_POOL_NAME, not imported"
		return 2
	}

	_WARN "exporting $OS_INSTALLER_ZFS_POOL_NAME"
	zpool export -f $OS_INSTALLER_ZFS_POOL_NAME
}
