_init_disk_encryption_get_device() {
  _os_installer_disk_dev_encrypted=${conf_os_installer_disk_dev}p2
  _os_installer_disk_zfs_dev=${conf_os_installer_disk_dev}p2.eli
}

_init_disk_encryption() {
  log_detail "setting up geli on $conf_os_installer_disk_dev"
  printf '%s' "$os_installer_disk_passphrase" | geli init -g -b -J - -l 256 -s 4096 $_os_installer_disk_dev_encrypted
}

_open_disk_encryption() {
  printf '%s' "$os_installer_disk_passphrase" | geli attach -j - $_os_installer_disk_dev_encrypted
}

_close_encrypted_disks() {
  [ -z "$_os_installer_disk_zfs_dev" ] && {
    log_warn "encrypted device not found"
    return 0
  }

  [ ! -e "$_os_installer_disk_zfs_dev" ] && {
    log_warn "encrypted device does not exist: $_os_installer_disk_zfs_dev"
    return 0
  }

  geli detach $_os_installer_disk_zfs_dev
}

_backup_disk_encryption_headers() {
  geli backup $_os_installer_disk_dev_encrypted $conf_os_installer_disk_dev_name/geli
}
