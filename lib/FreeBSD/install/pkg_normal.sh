pkg_update() {
  pkg "$pkg_options" upgrade "$freebsd_pkg_options" "$@"
  pkg "$pkg_options" autoremove "$freebsd_pkg_options" "$@"
}

pkg_install() {
  pkg "$pkg_options" install "$freebsd_pkg_options" "$@"
}

pkg_uninstall() {
  pkg "$pkg_options" delete "$freebsd_pkg_options" "$@"
}

pkg_is_installed() {
  pkg "$pkg_options" info -e "$1" 2>/dev/null
}

pkg_bootstrap() {
  if [ -n "$root" ] && [ "$root" != "/" ]; then
    _pkg_package_cache_already_mounted || _pkg_package_cache_mount
    pkg_options="-r $root"
  fi

  _pkg_enable_proxy

  ASSUME_ALWAYS_YES=yes pkg "$pkg_options" update -q
}
