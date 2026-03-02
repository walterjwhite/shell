_jail_configure() {
  local _pre_jail_pwd=$PWD

  jail_conf_path=$_JAIL_PATH/.jail
  . $jail_conf_path

  validation_require "$os_installer_jail_name" os_installer_jail_name

  local _jail_root_path=$_os_installer_jail_zfs_mountpoint/$os_installer_jail_name

  local _jail_install_name=${os_installer_jail_prefix}-$os_installer_jail_name

  conf_os_installer_system_name=$os_installer_jail_name
  conf_os_installer_mountpoint=$_jail_root_path

  _jail_get_id
}

_jail_get_id() {
  local _jail_id=$(grep jail_ /etc/devfs.rules 2>/dev/null | sed -e 's/^.*=//' -e 's/]//')
  [ -z "$_jail_id" ] && {
    local _jail_id=10
    return
  }

  local _jail_id=$(($_jail_id + 1))
}

_jail_do_setup() {
  local setup_path=$_JAIL_PATH/$1-setup
  [ ! -e $setup_path ] && {
    log_debug "$setup_path does not exist: $PWD"
    return
  }

  log_detail "running $setup_path"
  local setup_script
  for setup_script in $(find $setup_path -type f); do
    log_detail "running $setup_script"
    . $setup_script
  done
}

_jail_create_zfs_datasets() {
  log_info "creating ZFS datasets $_os_installer_jail_zfs_dataset/$os_installer_jail_name"

  zfs create -o mountpoint=$_OS_CONTAINER_MOUNTPOINT/$os_installer_jail_name $_os_installer_jail_zfs_dataset/$os_installer_jail_name
}
