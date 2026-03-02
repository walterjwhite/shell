
_init_chroot_apps() {
  local installed_file parent_dir
  for installed_file in $(cat $LIBRARY_PATH/install/.files $LIBRARY_PATH/os-installer/.files); do
    parent_dir=$conf_os_installer_mountpoint/$(dirname $installed_file)
    mkdir -p $parent_dir

    cp $installed_file $parent_dir
  done
}

_get_underlying_device() {
  printf '%s\n' "${1%%.eli}"
}
