_BOOT_LOADER_GRUB() {
	[ -n "$OS_INSTALLER_ZFS_POOL_NAME" ] && {
		mkdir -p /etc/portage/package.use
		printf "sys-boot/grub libzfs\n" >>/etc/portage/package.use/grub
	}

	_PACKAGE_INSTALL sys-boot/grub

	_BOOT_LOADER_GRUB_${GENTOO_BOOT_METHOD}
}

_BOOT_LOADER_GRUB_BIOS() {
	grub-probe /boot
}

_BOOT_LOADER_GRUB_UEFI() {
	_PACKAGE_INSTALL sys-boot/shim sys-boot/mokutil sys-boot/efibootmgr

	grub-probe /boot/efi

	cp /usr/share/shim/BOOTX64.EFI /efi/EFI/Gentoo/shimx64.efi
	cp /usr/share/shim/mmx64.efi /efi/EFI/Gentoo/mmx64.efi
	cp /usr/lib/grub/grub-x86_64.efi.signed /efi/EFI/Gentoo/grubx64.efi


	grub-install --efi-directory=/efi

	mkdir -p /etc/env.d
	printf 'GRUB_CFG=/efi/EFI/Gentoo/grub.cfg\n' >>/etc/env.d/99grub
}






