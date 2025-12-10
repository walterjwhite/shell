_mounts() {
	mkdir $_CONF_OS_INSTALLER_MOUNTPOINT/dev 2>/dev/null
	mount -t devfs devfs $_CONF_OS_INSTALLER_MOUNTPOINT/dev && _defer _umount_dev

	_mount_swap

	_ chroot $_CONF_OS_INSTALLER_MOUNTPOINT mount -a
}

_write_fstab() {
	mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/etc
	printf '# efi partition\n' >$_CONF_OS_INSTALLER_MOUNTPOINT/etc/fstab
	printf '%s /boot/efi msdosfs rw 2 2\n' $FREEBSD_ESP_DEVICE >>$_CONF_OS_INSTALLER_MOUNTPOINT/etc/fstab
}

_mount_remote_pkg_cache() {
	mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/var/cache/pkg
	ssh $_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE ls /var/cache/pkg >/dev/null 2>&1 || return $?

	sshfs -o StrictHostKeyChecking=no $_CONF_FREEBSD_INSTALLER_PACKAGE_CACHE:/var/cache/pkg $_CONF_OS_INSTALLER_MOUNTPOINT/var/cache/pkg && _defer _umount_pkg_cache
}

_mount_swap() {
	local swap_device=$(grep swap $_CONF_OS_INSTALLER_MOUNTPOINT/etc/fstab 2>/dev/null | awk {'print$1'})
	[ -n "$swap_device" ] && {
		_DETAIL "Activating swap: $swap_device"
		swapon $swap_device
		return 0
	}

	_WARN "No swap detected"
}



