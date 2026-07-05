pkg_update_install_media() {
  _pkg_setup_chroot

  sudo_run chroot "$APP_PLATFORM_ROOT" pkg upgrade "$freebsd_pkg_options" "$@"
  sudo_run chroot "$APP_PLATFORM_ROOT" pkg autoremove "$freebsd_pkg_options" "$@"

  local _return_status=$?

  sudo_run umount "$APP_PLATFORM_ROOT/dev"

  return "$_return_status"
}

pkg_install_install_media() {
  _pkg_setup_chroot

  sudo_run chroot "$APP_PLATFORM_ROOT" pkg install "$freebsd_pkg_options" "$@"

  local _return_status=$?

  sudo_run umount "$APP_PLATFORM_ROOT/dev"

  return "$_return_status"
}

pkg_uninstall_install_media() {
  _pkg_setup_chroot

  sudo_run chroot "$APP_PLATFORM_ROOT" pkg delete "$freebsd_pkg_options" "$@"

  local _return_status=$?

  sudo_run umount "$APP_PLATFORM_ROOT/dev"

  return "$_return_status"
}

pkg_is_installed_install_media() {
  _pkg_setup_chroot

  sudo_run chroot "$APP_PLATFORM_ROOT" pkg info -e "$1" 2>/dev/null

  local _return_status=$?

  sudo_run umount "$APP_PLATFORM_ROOT/dev"

  return "$_return_status"
}

pkg_bootstrap_install_media() {
  log_warn "uFS root FS detected, assuming install media is present"

  _pkg_setup_chroot

  ASSUME_ALWAYS_YES=yes
  sudo_run chroot "$APP_PLATFORM_ROOT" pkg bootstrap -f
  sudo_run chroot "$APP_PLATFORM_ROOT" pkg update -q
  sudo_run chroot "$APP_PLATFORM_ROOT" pkg install "$freebsd_pkg_options" "$PLATFORM_PACKAGES"

  sudo_run umount "$APP_PLATFORM_ROOT/dev"
}

_pkg_setup_chroot() {
  sudo_run mount -t devfs devfs "$APP_PLATFORM_ROOT/dev"
  sudo_run cp /etc/resolv.conf "$APP_PLATFORM_ROOT/etc/resolv.conf"
}
