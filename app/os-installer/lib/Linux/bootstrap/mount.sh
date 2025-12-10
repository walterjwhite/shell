_mounts() {
	mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/dev $_CONF_OS_INSTALLER_MOUNTPOINT/run $_CONF_OS_INSTALLER_MOUNTPOINT/sys $_CONF_OS_INSTALLER_MOUNTPOINT/proc

	_mount_rbind dev
	_mount_rbind run
	_mount_rbind sys
	mount --types proc /proc $_CONF_OS_INSTALLER_MOUNTPOINT/proc

	mkdir -p $_CONF_OS_INSTALLER_MOUNTPOINT/boot $_CONF_OS_INSTALLER_MOUNTPOINT/efi
	mount ${_CONF_OS_INSTALLER_DISK_DEV_EFI_PARTITION} $_CONF_OS_INSTALLER_MOUNTPOINT/boot
	mount ${_CONF_OS_INSTALLER_DISK_DEV_EFI_PARTITION} $_CONF_OS_INSTALLER_MOUNTPOINT/efi
}

_mount_rbind() {
	mount --rbind /$1 $_CONF_OS_INSTALLER_MOUNTPOINT/$1
	mount --make-rslave $_CONF_OS_INSTALLER_MOUNTPOINT/$1
}

_write_fstab() {
	[ -f /etc/fstab ] && mv /etc/fstab /etc/fstab.0

	local esp_uuid=$(_disk_partition_get_uuid $_CONF_OS_INSTALLER_DISK_DEV_EFI_PARTITION)

	printf '# <fs>      <mountpoint>  <type>    <opts>    <dump> <pass>\n' >>/etc/fstab
	printf '# ESP\n' >>/etc/fstab

	case $_CONF_OS_INSTALLER_INIT in
	SYSTEMD)
		printf 'UUID=%s /efi vfat defaults,noatime,uid=0,gid=0,umask=0077,x-systemd.automount,x-systemd.idle-timeout=600 0 2\n' $esp_uuid >>/etc/fstab
		;;
	OPENRC)
		printf 'UUID=%s /boot vfat defaults 0 0\n' $esp_uuid >>/etc/fstab
		printf 'UUID=%s /efi vfat defaults 0 0\n\n' $esp_uuid >>/etc/fstab
		;;
	esac
}
