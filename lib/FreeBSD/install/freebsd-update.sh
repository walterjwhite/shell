_freebsd_update() {
  local _freebsd_update_configuration_file=$freebsd_root/etc/freebsd-update.conf
  local _freebsd_update_options

  [ -n "$freebsd_root" ] && _freebsd_update_options="-b $jail_zfs_mountpoint/$jail_name"

  grep -qs '^CreateBootEnv yes' "$_freebsd_update_configuration_file" || {
    printf '# disable creation of boot environments, will be handled automatically via system-maintenance app\n' >>"$_freebsd_update_configuration_file"
    printf 'CreateBootEnv no\n' >>"$_freebsd_update_configuration_file"
  }

  env PAGER=cat freebsd-update $_freebsd_update_options "$@" --not-running-from-cron fetch install
}
