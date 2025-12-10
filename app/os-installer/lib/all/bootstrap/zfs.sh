_init_disk_zfs() {
	OS_INSTALLER_ZFS_POOL_NAME=z_$_CONF_OS_INSTALLER_DISK_DEV_NAME

	_zfs_zpool_create
	_zfs_create_datasets

	_zpool_export
}

_zfs_zpool_create() {
	_DETAIL "Creating zpool $OS_INSTALLER_ZFS_POOL_NAME on $OS_INSTALLER_DISK_ZFS_DEV"

	zpool create -f \
		$_ZPOOL_OPTIONS -R "$_CONF_OS_INSTALLER_MOUNTPOINT" \
		$OS_INSTALLER_ZFS_POOL_NAME $OS_INSTALLER_DISK_ZFS_DEV
}

_zfs_mount_do() {
	local zfs_mountpoint
	for zfs_mountpoint in "$@"; do
		zfs mount $OS_INSTALLER_ZFS_POOL_NAME/$zfs_mountpoint
	done
}

_zpool_export() {
	cd /tmp
	zpool export $OS_INSTALLER_ZFS_POOL_NAME
}
