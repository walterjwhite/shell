patch_sysctl() {
  _module_find -exec $APP_LIBRARY_PATH/bin/key_value /etc/sysctl.conf {} \;

  [ -n "$_in_container" ] && return

  _append_jail_sysctl
}

_append_jail_sysctl() {
  log_detail "appending jail sysctl"

  local container_mountpoint
  for container_mountpoint in $(_container_mount_points); do
    local sysctl_container_conf=$container_mountpoint/etc/sysctl.conf

    if [ -e $sysctl_container_conf ]; then
      log_detail "appending container sysctl: $container_mountpoint"
      printf '\n\n# %s container sysctl configuration\n' $(basename $container_mountpoint) >>/etc/sysctl.conf

      cat $sysctl_container_conf >>/etc/sysctl.conf
    else
      log_warn "container sysctl not found: $sysctl_container_conf"
    fi
  done
}
