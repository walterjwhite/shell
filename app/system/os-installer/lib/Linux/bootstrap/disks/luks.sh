_init_disk_encryption() {
  [ -e $_os_installer_disk_zfs_dev ] && exit_with_error "device already exists: $_os_installer_disk_zfs_dev"

  printf '%s\n' "$os_installer_disk_passphrase" | cryptsetup luksFormat --batch-mode -c $os_installer_luks_cipher -s $os_installer_luks_key_size --hash $os_installer_luks_hash $_os_installer_disk_dev_encrypted
}

_init_disk_encryption_get_device() {
  case $conf_os_installer_disk_dev in
  /dev/nvme*)
    log_warn "nVMe drive detected, prefixing partitions with 'p'"
    local _os_installer_disk_dev_partition_prefix=p
    ;;
  esac

  _os_installer_disk_dev_encrypted=${conf_os_installer_disk_dev}${_os_installer_disk_dev_partition_prefix}$os_installer_disk_dev_encrypted_partition_id
  _os_installer_disk_zfs_dev=/dev/mapper/$_os_installer_zfs_pool_name
}

_open_disk_encryption() {
  printf '%s' "$os_installer_disk_passphrase" | cryptsetup luksOpen $_os_installer_disk_dev_encrypted $_os_installer_zfs_pool_name
}

_close_encrypted_disks() {
  [ -z "$_os_installer_disk_zfs_dev" ] && _init_disk_encryption_get_device

  [ ! -e $_os_installer_disk_zfs_dev ] && {
    log_warn "device does not exist, nothing to do: $_os_installer_disk_zfs_dev"
    unset _os_installer_disk_zfs_dev
    return
  }

  log_info "closing LUKS: $_os_installer_zfs_pool_name"
  exec_attempts=3 exec_delay=5 exec_wrap cryptsetup luksClose $_os_installer_zfs_pool_name
}

_backup_disk_encryption_headers() {
  cryptsetup luksHeaderBackup $_os_installer_disk_dev_encrypted --header-backup-file=$conf_os_installer_disk_dev_name/luks
}
