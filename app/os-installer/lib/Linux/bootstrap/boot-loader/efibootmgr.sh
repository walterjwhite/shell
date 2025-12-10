_BOOT_LOADER_EFIBOOTMGR() {
	_PACKAGE_INSTALL sys-boot/efibootmgr

	_boot_loader_efibootmgr_install

}

_boot_loader_efibootmgr_install() {
	local kernel kernel_version
	for kernel in $(find /boot -maxdepth 1 -name 'vmlinuz*' ! -name '*.old'); do
		kernel_version=$(printf '%s' $kernel | sed -e 's/vmlinuz-//' -e 's/^\/boot\///')

		[ ! -e /efi/EFI/gentoo/$kernel_version ] && {
			mkdir -p /efi/EFI/gentoo/$kernel_version
			cp /boot/vmlinuz-$kernel_version /efi/EFI/gentoo/$kernel_version/kernel
			cp /boot/initramfs-$kernel_version.img /efi/EFI/gentoo/$kernel_version/initramfs
			cp /boot/System.map-$kernel_version /efi/EFI/gentoo/$kernel_version/System.map
			cp /boot/config-$kernel_version /efi/EFI/gentoo/$kernel_version/config

			_boot_loader_efibootmgr_create "$kernel_version"
		}
	done
}

_boot_loader_efibootmgr_create() {
	_boot_loader_efibootmgr_args

	efibootmgr --create --disk $_CONF_OS_INSTALLER_DISK_DEV --part $_CONF_OS_INSTALLER_DISK_DEV_BOOT_PARTITION_ID --label "Gentoo $_CONF_OS_INSTALLER_SYSTEM_NAME - $1" --loader \
		"\\EFI\\gentoo\\$1\\kernel" --unicode "$GENTOO_BOOT_LOADER_ARGS initrd=\\EFI\\gentoo\\$1\\initramfs"
}

_boot_loader_efibootmgr_args() {
	GENTOO_BOOT_LOADER_ARGS="$GENTOO_KERNEL_CMDLINE_ARGS"
	[ -n "$OS_INSTALLER_DISK_DEV_ENCRYPTED" ] && {
		GENTOO_BOOT_LOADER_LUKS_DEVICE_UUID=$(lsblk -no name,uuid $OS_INSTALLER_DISK_DEV_ENCRYPTED | head -1 | awk {'print$2'}) || _ERROR "Unable to determine UUID for $OS_INSTALLER_DISK_DEV_LUKS"
		GENTOO_BOOT_LOADER_ARGS="$GENTOO_BOOT_LOADER_ARGS rd.luks.uuid=$GENTOO_BOOT_LOADER_LUKS_DEVICE_UUID"
	}
	[ -n "$OS_INSTALLER_ZFS_POOL_NAME" ] && {
		GENTOO_BOOT_LOADER_ARGS="$GENTOO_BOOT_LOADER_ARGS root=zfs:$OS_INSTALLER_ZFS_POOL_NAME/gentoo"
	}
}

_boot_loader_efibootmgr_delete() {
	local efi_boot_line efi_boot_id local gentoo_kernel_version
	efibootmgr -u | $_CONF_GNU_GREP -P '^Boot[\d]{4}' | while read efi_boot_line; do
		efi_boot_id=$(printf '%s' "$efi_boot_line" | sed -e 's/^Boot//' -e 's/ .*$//' -e 's/\*//')
		gentoo_kernel_version=$(printf '%s' "$efi_boot_line" | sed -e 's/.*\\EFI\\gentoo\\//' -e 's/\\.*$//' | $_CONF_GNU_GREP -P '[\d]{1,}\..*' | head -1)

		[ ! -e /boot/vmlinuz-$gentoo_kernel_version ] && {
			_WARN "Deleting boot entry: $efi_boot_id - $gentoo_kernel_version no longer exists"

			rm -rf /efi/EFI/gentoo/$gentoo_kernel_version
			efibootmgr -B -b $efi_boot_id
		}
	done
}
