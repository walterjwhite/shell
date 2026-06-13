pkg_update_install_media() {
  _pkg_setup_chroot

  local _return_status
  chroot "$APP_PLATFORM_ROOT" pkg upgrade "$freebsd_pkg_options" "$@"
  chroot "$APP_PLATFORM_ROOT" pkg autoremove "$freebsd_pkg_options" "$@"

  _return_status=$?

  umount "$APP_PLATFORM_ROOT/dev"

  return "$_return_status"
}

pkg_install_install_media() {
  _pkg_setup_chroot

  local _return_status
  chroot "$APP_PLATFORM_ROOT" pkg install "$freebsd_pkg_options" "$@"

  _return_status=$?

  umount "$APP_PLATFORM_ROOT/dev"

  return "$_return_status"
}

pkg_uninstall_install_media() {
  _pkg_setup_chroot

  local _return_status
  chroot "$APP_PLATFORM_ROOT" pkg delete "$freebsd_pkg_options" "$@"

  _return_status=$?

  umount "$APP_PLATFORM_ROOT/dev"

  return "$_return_status"
}

pkg_is_installed_install_media() {
  _pkg_setup_chroot

  local _return_status
  chroot "$APP_PLATFORM_ROOT" pkg info -e "$1" 2>/dev/null

  _return_status=$?

  umount "$APP_PLATFORM_ROOT/dev"

  return "$_return_status"
}

pkg_bootstrap_install_media() {
  log_warn "uFS root FS detected, assuming install media is present"

  _pkg_setup_chroot

  ASSUME_ALWAYS_YES=yes chroot "$APP_PLATFORM_ROOT" pkg bootstrap -f
  chroot "$APP_PLATFORM_ROOT" pkg update -q
  chroot "$APP_PLATFORM_ROOT" pkg install "$freebsd_pkg_options" "$PLATFORM_PACKAGES"

  umount "$APP_PLATFORM_ROOT/dev"
}

_pkg_setup_chroot() {
  mount -t devfs devfs "$APP_PLATFORM_ROOT/dev"
  cp /etc/resolv.conf "$APP_PLATFORM_ROOT/etc/resolv.conf"
}
