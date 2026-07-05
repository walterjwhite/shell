_boot_loader_secure_boot() {
  [ -z "$os_installer_kernel_key_pem" ] && {
    log_warn 'gentoo_kernel_key_pem is unset, not configuring secure boot'
    return
  }
  [ -z "$os_installer_kernel_key_der" ] && {
    log_warn 'gentoo_kernel_key_der is unset, not configuring secure boot'
    return
  }

  _package app-crypt/sbsigntools

  openssl x509 -in "$os_installer_kernel_key_pem" -inform PEM -out "$os_installer_kernel_key_der" -outform DER
  mokutil --import "$os_installer_kernel_key_der"

  efibootmgr --create --disk /dev/boot-disk --part boot-partition-id --loader '\EFI\Gentoo\shimx64.efi' --label 'GRUB via Shim' --unicode
}
