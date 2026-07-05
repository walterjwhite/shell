_cleanup_prior_installation() {
  _cleanup_processes

  _cleanup_mounts
  _zpool_export
  _close_encrypted_disks

  _remove_status
}

_cleanup_mounts() {
  mount | grep -qm1 " on $conf_os_installer_mountpoint" || return 0

  umount -f$os_installer_umount_options $(mount | grep " on $conf_os_installer_mountpoint" | awk {'print$3'} | sort -r)
  mount | grep -qm1 $conf_os_installer_mountpoint && exit_with_error "unable to unmount all volumes, please check"

  return 0
}

_remove_status() {
  [ -z "$clean" ] && return 1

  log_warn "cleaning up prior configuration history"

  rm -rf $conf_os_installer_execution_log
  find $(dirname $log_logfile)/ -type f -name 'os-installer-*' -exec rm -f {} +
}
