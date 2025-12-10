_zfs_create_datasets() {
	zfs create -o mountpoint=none $OS_INSTALLER_ZFS_POOL_NAME/ROOT
	zfs create -o mountpoint=/ $OS_INSTALLER_ZFS_POOL_NAME/ROOT/default

	zfs create -o mountpoint=/home -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/home

	zfs create -o mountpoint=/tmp -o exec=on -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/tmp

	zfs create -o mountpoint=/usr/ports -p -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/usr/ports
	zfs create -o mountpoint=/usr/src $OS_INSTALLER_ZFS_POOL_NAME/usr/src


	zfs create -o mountpoint=/var/audit -p -o exec=off -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/var/audit

	zfs create -o mountpoint=/var/cache/pkg -p -o exec=off -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/var/cache/pkg
	zfs create -o mountpoint=/var/crash -o exec=off -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/var/crash

	zfs create -o mountpoint=/var/log -o exec=off -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/var/log

	zfs create -o mountpoint=/var/mail -o atime=on $OS_INSTALLER_ZFS_POOL_NAME/var/mail
	zfs create -o mountpoint=/var/tmp -o setuid=off $OS_INSTALLER_ZFS_POOL_NAME/var/tmp

	zpool set bootfs=$OS_INSTALLER_ZFS_POOL_NAME/ROOT/default $OS_INSTALLER_ZFS_POOL_NAME

	zfs set canmount=noauto $OS_INSTALLER_ZFS_POOL_NAME/ROOT/default
}

_zfs_mount() {
	_zfs_mount_do ROOT/default home tmp usr/ports usr/src var/audit var/cache/pkg var/crash var/log var/mail var/tmp
}
