_INIT_DRACUT() {
	mkdir -p /etc/dracut.conf.d

	printf 'sys-kernel/installkernel dracut\n' >>/etc/portage/package.use/installkernel

	local dracut_modules
	[ -n "$OS_INSTALLER_DISK_DEV_ENCRYPTED" ] && {
		dracut_modules="$dracut_modules crypt "
	}

	[ -n "$OS_INSTALLER_ZFS_POOL_NAME" ] && {
		[ "$GENTOO_BOOT_FS" = "zpool" ] && {
			dracut_modules="$dracut_modules zfs"
		}
	}

	[ -z "$GENTOO_FSCK" ] && printf 'nofsck="yes"\n' >>/etc/dracut.conf.d/no-fsck.conf

	printf 'add_dracutmodules+=" %s"\n' "$dracut_modules " >>/etc/dracut.conf.d/modules.conf
}

