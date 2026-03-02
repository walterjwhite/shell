patch_boot_loader() {
  _module_find -exec $APP_LIBRARY_PATH/bin/key_value /boot/loader.conf {} \;

  [ -n "$_in_container" ] && return

  _append_container_boot_loader_conf
}

_append_container_boot_loader_conf() {
  log_detail "appending container boot loader confs"

  local container_mountpoint
  for container_mountpoint in $(_container_mount_points); do
    local boot_loader_container_conf=$container_mountpoint/boot/loader.conf

    if [ -e $boot_loader_container_conf ]; then
      log_detail "appending container boot loader conf: $container_mountpoint"
      printf '\n\n# %s container boot_loader configuration\n' $container_mountpoint >>/boot/loader.conf

      cat $boot_loader_container_conf >>/boot/loader.conf
    else
      log_warn "container boot loader conf not found: $boot_loader_container_conf"
    fi
  done
}
