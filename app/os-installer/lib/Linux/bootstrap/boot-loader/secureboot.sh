_BOOT_LOADER_SECURE_BOOT() {
	[ -z "$GENTOO_KERNEL_KEY_PEM" ] && {
		_WARN 'GENTOO_KERNEL_KEY_PEM is unset, not configuring secure boot'
		return
	}
	[ -z "$GENTOO_KERNEL_KEY_DER" ] && {
		_WARN 'GENTOO_KERNEL_KEY_DER is unset, not configuring secure boot'
		return
	}

	_package app-crypt/sbsigntools

	openssl x509 -in "$GENTOO_KERNEL_KEY_PEM" -inform PEM -out "$GENTOO_KERNEL_KEY_DER" -outform DER
	mokutil --import "$GENTOO_KERNEL_KEY_DER"

	efibootmgr --create --disk /dev/boot-disk --part boot-partition-id --loader '\EFI\Gentoo\shimx64.efi' --label 'GRUB via Shim' --unicode
}
