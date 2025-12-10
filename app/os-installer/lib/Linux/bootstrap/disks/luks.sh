_init_disk_encryption() {
	[ -e $OS_INSTALLER_DISK_ZFS_DEV ] && _ERROR "$OS_INSTALLER_DISK_ZFS_DEV already exists"

	printf '%s\n' "$OS_INSTALLER_DISK_PASSPHRASE" | cryptsetup luksFormat --batch-mode -c $GENTOO_LUKS_CIPHER -s $GENTOO_LUKS_KEY_SIZE --hash $GENTOO_LUKS_HASH $OS_INSTALLER_DISK_DEV_ENCRYPTED
}

_init_disk_encryption_get_device() {
	case $_CONF_OS_INSTALLER_DISK_DEV in
	/dev/nvme*)
		_WARN "NVMe drive detected, prefixing partitions with 'p'"
		OS_INSTALLER_DISK_DEV_PARTITION_PREFIX=p
		;;
	esac

	OS_INSTALLER_DISK_DEV_ENCRYPTED=${_CONF_OS_INSTALLER_DISK_DEV}${OS_INSTALLER_DISK_DEV_PARTITION_PREFIX}$OS_INSTALLER_DISK_DEV_ENCRYPTED_PARTITION_ID

	GENTOO_LUKS_NAME=$(_disk_partition_get_uuid $OS_INSTALLER_DISK_DEV_ENCRYPTED)

	[ -z "$GENTOO_LUKS_NAME" ] && return

	OS_INSTALLER_DISK_ZFS_DEV=/dev/mapper/$GENTOO_LUKS_NAME
}

_open_disk_encryption() {
	printf '%s' "$OS_INSTALLER_DISK_PASSPHRASE" | cryptsetup luksOpen $OS_INSTALLER_DISK_DEV_ENCRYPTED $GENTOO_LUKS_NAME
}

_close_encrypted_disks() {
	[ -z "$OS_INSTALLER_DISK_ZFS_DEV" ] && _init_disk_encryption_get_device

	[ ! -e $OS_INSTALLER_DISK_ZFS_DEV ] && {
		unset GENTOO_LUKS_NAME OS_INSTALLER_DISK_ZFS_DEV
		return
	}

	_INFO "closing LUKS: $GENTOO_LUKS_NAME"
	[ -e $OS_INSTALLER_DISK_ZFS_DEV ] && {
		cryptsetup luksClose $GENTOO_LUKS_NAME
		return
	}

	return 0
}

_backup_disk_encryption_headers() {
	cryptsetup luksHeaderBackup $OS_INSTALLER_DISK_DEV_ENCRYPTED --header-backup-file=$_CONF_OS_INSTALLER_DISK_DEV_NAME/luks
}
