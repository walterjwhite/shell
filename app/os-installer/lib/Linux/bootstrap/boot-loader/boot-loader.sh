_boot_loader_configure() {
	[ -e /sys/firmware/efi/efivars/ ] && return

	_WARN "System was booted using BIOS and not EFI, falling back to BIOS to boot build system"
	GENTOO_BOOT_LOADER=grub
	GENTOO_BOOT_METHOD=BIOS
}
