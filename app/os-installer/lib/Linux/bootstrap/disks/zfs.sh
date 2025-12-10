_zfs_create_datasets() {
	zfs create -o mountpoint=/ -o canmount=noauto $OS_INSTALLER_ZFS_POOL_NAME/gentoo
	zfs create -o mountpoint=/home -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/home

	zfs create -o mountpoint=/tmp -o exec=on -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/tmp

	zfs create -o mountpoint=/usr/src -p -o exec=on -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/usr/src

	zfs create -o mountpoint=/var/cache/distfiles -p -o exec=off -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/var/cache/distfiles
	zfs create -o mountpoint=/var/db/repos/gentoo -p -o exec=off -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/var/db/repos/gentoo
	zfs create -o mountpoint=/var/log -p -o exec=off -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/var/log
	zfs create -o mountpoint=/var/tmp/portage -p -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/var/tmp/portage

	udevadm trigger

	zgenhostid -f
	zpool set bootfs=$OS_INSTALLER_ZFS_POOL_NAME/gentoo $OS_INSTALLER_ZFS_POOL_NAME
}

_zfs_mount() {
	_zfs_mount_do gentoo home tmp var/log usr/src var/db/repos/gentoo var/cache/distfiles var/tmp/portage
}
