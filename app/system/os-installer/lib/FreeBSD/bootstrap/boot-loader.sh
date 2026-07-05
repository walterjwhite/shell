lib io/file.sh

_boot_loader() {
  [ -z "$(awk '{if ($2=="/boot/efi") printf("%s\n",$1);}' $conf_os_installer_mountpoint/etc/fstab)" ] && {
    log_warn "eSP not detected"
    return 1
  }

  _bsd_prepare_esp || {
    log_warn "failed to prepare ESP"
    return 1
  }

  local boot_label="FreeBSD $os_installer_version - $conf_os_installer_system_name"
  _bsd_has_boot_entry && {
    log_warn "uEFI boot entry already exists, skipping creation"
    return
  }

  _bsd_efibootmgr_create
}

_bsd_prepare_esp() {
  log_info "installing loader.efi onto ESP"
  mkdir -p "$conf_os_installer_mountpoint/boot/efi/efi/freebsd"
  cp "$conf_os_installer_mountpoint/boot/loader.efi" "$conf_os_installer_mountpoint/boot/efi/efi/freebsd/loader.efi"
}

_bsd_efibootmgr_create() {
  [ -e "$conf_os_installer_mountpoint/boot/efi/efi/freebsd/loader.efi" ] || {
    log_warn "fBSD loader is missing: $conf_os_installer_mountpoint/boot/efi/efi/freebsd/loader.efi"
    return 1
  }

  log_info "creating UEFI boot entry"
  efibootmgr --create --activate --label "$boot_label" --loader "$conf_os_installer_mountpoint/boot/efi/efi/freebsd/loader.efi"
}

_bsd_has_boot_entry() {
  efibootmgr | sed 1,4d | grep -cqm1 "$boot_label"
}
