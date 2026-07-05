_init_disk_zfs() {
  _zfs_zpool_create
  _zfs_create_datasets

  _zpool_export
}

_zfs_zpool_create() {
  log_detail "creating zpool $_os_installer_zfs_pool_name on $_os_installer_disk_zfs_dev"

  zpool create -f \
    $_ZPOOL_OPTIONS -R "$conf_os_installer_mountpoint" \
    $_os_installer_zfs_pool_name $_os_installer_disk_zfs_dev
}

_zfs_mount_do() {
  local zfs_mountpoint
  for zfs_mountpoint in "$@"; do
    zfs mount $_os_installer_zfs_pool_name/$zfs_mountpoint
  done
}

_zpool_export() {
  cd /tmp
  [ -z "$_os_installer_zfs_pool_name" ] && return 1

  zpool list -H $_os_installer_zfs_pool_name >/dev/null 2>&1 || {
    log_warn "no need to export $_os_installer_zfs_pool_name, not imported"
    return 2
  }

  log_warn "exporting $_os_installer_zfs_pool_name"
  mount | grep "$conf_os_installer_mountpoint"
  exec_attempts=3 exec_delay=5 exec_wrap zpool export -f $_os_installer_zfs_pool_name || exit_with_error "failed to export $_os_installer_zfs_pool_name"
}
