_boot_loader_efibootmgr() {
  _package_install_new_only sys-boot/efibootmgr

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

  efibootmgr --create --disk $conf_os_installer_disk_dev --part $conf_os_installer_disk_dev_boot_partition_id --label "Gentoo $conf_os_installer_system_name - $1" --loader \
    "\\EFI\\gentoo\\$1\\kernel" --unicode "$_os_installer_boot_loader_args initrd=\\EFI\\gentoo\\$1\\initramfs"
}

_boot_loader_efibootmgr_args() {
  _os_installer_boot_loader_args="$os_installer_kernel_cmdline_args"
  [ -n "$_os_installer_disk_dev_encrypted" ] && {
    _os_installer_boot_loader_luks_device_uuid=$(lsblk -no name,uuid $_os_installer_disk_dev_encrypted | head -1 | awk {'print$2'}) || exit_with_error "unable to determine UUID for $os_installer_disk_dev_luks"
    _os_installer_boot_loader_args="$_os_installer_boot_loader_args rd.luks.uuid=$_os_installer_boot_loader_luks_device_uuid"
  }
  [ -n "$_os_installer_zfs_pool_name" ] && {
    _os_installer_boot_loader_args="$_os_installer_boot_loader_args root=zfs:$_os_installer_zfs_pool_name/gentoo"
  }
}

_boot_loader_efibootmgr_delete() {
  local efi_boot_line efi_boot_id local gentoo_kernel_version
  efibootmgr -u | $GNU_GREP -P '^Boot[\d]{4}' | while read efi_boot_line; do
    efi_boot_id=$(printf '%s' "$efi_boot_line" | sed -e 's/^Boot//' -e 's/ .*$//' -e 's/\*//')
    gentoo_kernel_version=$(printf '%s' "$efi_boot_line" | sed -e 's/.*\\EFI\\gentoo\\//' -e 's/\\.*$//' | $GNU_GREP -P '[\d]{1,}\..*' | head -1)

    [ ! -e /boot/vmlinuz-$gentoo_kernel_version ] && {
      log_warn "deleting boot entry: $efi_boot_id - $gentoo_kernel_version no longer exists"

      rm -rf /efi/EFI/gentoo/$gentoo_kernel_version
      efibootmgr -B -b $efi_boot_id
    }
  done
}
