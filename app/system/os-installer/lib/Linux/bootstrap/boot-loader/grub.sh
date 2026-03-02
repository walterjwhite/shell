_boot_loader_grub() {
  [ -n "$_os_installer_zfs_pool_name" ] && {
    mkdir -p /etc/portage/package.use
    printf "sys-boot/grub libzfs\n" >>/etc/portage/package.use/grub
  }

  _package_install_new_only sys-boot/grub

  _boot_loader_grub_${_os_installer_boot_method}
}

_boot_loader_grub_bios() {
  grub-probe /boot
}

_boot_loader_grub_uefi() {
  _package_install_new_only sys-boot/shim sys-boot/mokutil sys-boot/efibootmgr

  grub-probe /boot/efi

  cp /usr/share/shim/BOOTX64.EFI /efi/EFI/Gentoo/shimx64.efi
  cp /usr/share/shim/mmx64.efi /efi/EFI/Gentoo/mmx64.efi
  cp /usr/lib/grub/grub-x86_64.efi.signed /efi/EFI/Gentoo/grubx64.efi


  grub-install --efi-directory=/efi

  mkdir -p /etc/env.d
  printf 'GRUB_CFG=/efi/EFI/Gentoo/grub.cfg\n' >>/etc/env.d/99grub
}






