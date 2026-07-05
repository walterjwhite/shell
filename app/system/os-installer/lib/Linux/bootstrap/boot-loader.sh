_boot_loader() {
  [ ! -e /sys/firmware/efi/efivars/ ] && {
    log_warn "system was booted using BIOS and not EFI, falling back to BIOS to boot build system"
    _os_installer_boot_loader=grub
    _os_installer_boot_method=bios
  }

  _boot_loader_${_os_installer_boot_loader}
}
