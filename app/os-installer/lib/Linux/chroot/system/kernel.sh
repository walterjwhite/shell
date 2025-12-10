

_kernel() {
	_kernel_conf

	_kernel_luks_support
	_PACKAGE_INSTALL sys-kernel/$GENTOO_KERNEL

	_kernel_zfs_support
}

_kernel_conf() {
	case $GENTOO_INIT in
	BLISS | DRACUT | UGRD)
		local init_use=$(printf $GENTOO_INIT | tr '[:upper:]' '[:lower:]')
		printf 'USE="$USE %s"\n' "$init_use" >>/etc/portage/make.conf
		;;
	esac

	case $GENTOO_KERNEL in
	*-kernel | *-kernel-bin)
		GENTOO_DIST_KERNEL=1
		printf 'USE="$USE dist-kernel"\n' >>/etc/portage/make.conf
		;;
	*)
		printf 'USE="$USE symlink"\n' >>/etc/portage/make.conf
		;;
	esac
}

_kernel_manual_build() {
	case $GENTOO_KERNEL in
	*-kernel | *-kernel-bin) ;;
	*)

		_DETAIL "Building kernel $GENTOO_KERNEL"
		local opwd=$PWD

		cd /usr/src/linux
		cp /tmp/gentoo/system/kernel.config .

		make && make modules_install && make install

		cd $opwd
		;;
	esac
}

_kernel_zfs_support() {
	[ "$GENTOO_BOOT_FS" != "zpool" ] && {
		_WARN "boot -> $GENTOO_BOOT_FS, skipping ZFS"
		return 1
	}

	[ -z "$OS_INSTALLER_ZFS_POOL_NAME" ] && {
		_WARN "$OS_INSTALLER_ZFS_POOL_NAME, not set, skipping ZFS"
		return 2
	}

	[ -n "$GENTOO_DIST_KERNEL" ] && {
		[ -z "$container" ] && {
			printf 'sys-fs/zfs dist-kernel-cap\n' >>/etc/portage/package.use/zfs
		}
	}

	_PACKAGE_INSTALL sys-fs/zfs-kmod
	_PACKAGE_INSTALL sys-fs/zfs

	case $_SERVICE_$_CONF_OS_INSTALLER_INIT in
	OPENRC)
		_kernel_zfs_service_openrc
		;;
	SYSTEMD)
		_kernel_zfs_service_systemd
		;;
	esac
}

_kernel_zfs_service_openrc() {
	rc-update add zfs-import boot
	rc-update add zfs-mount boot
	rc-update add zfs-zed boot
}

_kernel_zfs_service_systemd() {
	systemctl enable zfs.target
	systemctl enable zfs-import-cache
	systemctl enable zfs-mount
	systemctl enable zfs-import.target

	systemctl enable zfs-trim-monthly@${OS_INSTALLER_ZFS_POOL_NAME}.timer
	systemctl enable zfs-scrub-monthly@${OS_INSTALLER_ZFS_POOL_NAME}.timer

	systemctl enable zfs-trim-weekly@${OS_INSTALLER_ZFS_POOL_NAME}.timer
	systemctl enable zfs-scrub-weekly@${OS_INSTALLER_ZFS_POOL_NAME}.timer
}

_kernel_luks_support() {
	[ -n "$OS_INSTALLER_DISK_DEV_ENCRYPTED" ] && _PACKAGE_INSTALL sys-fs/cryptsetup
}

_initramfs() {
	_INIT_$GENTOO_INIT

	case $GENTOO_INIT in
	BLISS | DRACUT | UGRD)
		emerge --config sys-kernel/$GENTOO_KERNEL
		;;
	esac
}

_kernel_container() {
	_kernel_zfs_support
}
