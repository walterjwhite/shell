_jail_post() {
  [ $_jail_execution_status -gt 0 ] && log_warn "jail provisioning completed with errors"

  service jail stop $_jail_install_name

  cd $_pre_jail_pwd

  _jail_rename

  _jail_do_setup post
  _jail_write_mounts

  _jail_update_mount_point
  _jail_update_post_jail
  _jail_update_jail_conf
  _jail_write_devfs
}

_jail_rename() {
  log_detail "renaming $_jail_install_name to $os_installer_jail_name"
  mv /etc/jail.conf.d/$_jail_install_name.conf /etc/jail.conf.d/$os_installer_jail_name.conf

  $GNU_SED -i "s/$_jail_install_name/$os_installer_jail_name/" /etc/jail.conf.d/$os_installer_jail_name.conf

  $GNU_SED -i "s/$_jail_install_name/$os_installer_jail_name/" /etc/devfs.rules
}

_jail_update_jail_conf() {
  _jail_insert_before_last "created"
  _jail_insert_before_last "prestop"
}

_jail_insert_before_last() {
  local action_file action=$1
  for action_file in $(find /usr/local/etc/walterjwhite/jails/$os_installer_jail_name/$action -type f | sort -V); do
    $GNU_SED -i "/}/i\    exec.$action += $action_file;" /etc/jail.conf.d/$os_installer_jail_name.conf
  done
}

_jail_write_devfs() {
  [ ! -e $_JAIL_PATH/devfs.rules ] && return

  printf '[jail_%s=%s]\n' "$os_installer_jail_name" "$_jail_id" >>/etc/devfs.rules
  cat $_JAIL_PATH/devfs.rules >>/etc/devfs.rules

  printf '\n\n' >>/etc/devfs.rules
}
