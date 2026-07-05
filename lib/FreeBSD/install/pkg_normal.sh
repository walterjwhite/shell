pkg_update() {
  pkg_bootstrap

  sudo_run pkg $pkg_options upgrade "$freebsd_pkg_options" "$@"
  sudo_run pkg $pkg_options autoremove "$freebsd_pkg_options" "$@"
}

pkg_install() {
  pkg_bootstrap

  sudo_run pkg $pkg_options install "$freebsd_pkg_options" "$@"
}

pkg_uninstall() {
  pkg_bootstrap

  sudo_run pkg $pkg_options delete "$freebsd_pkg_options" "$@"
}

pkg_is_installed() {
  pkg_bootstrap

  sudo_run pkg $pkg_options info -e "$1" 2>/dev/null
}

pkg_bootstrap() {
  if [ "$APP_PLATFORM_ROOT" != "/" ]; then
    _pkg_package_cache_already_mounted || _pkg_package_cache_mount
    pkg_options="-c $APP_PLATFORM_ROOT"
  fi

  _pkg_enable_proxy

  ASSUME_ALWAYS_YES=yes
  sudo_run pkg $pkg_options update -q
}
