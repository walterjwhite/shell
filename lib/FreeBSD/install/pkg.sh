package_update() {
  pkg_update${freebsd_pkg_suffix} "$@"
}

_package_install_do() {
  pkg_install${freebsd_pkg_suffix} "$@"
}

_package_uninstall_do() {
  pkg_uninstall${freebsd_pkg_suffix} "$@"
}

_package_is_installed() {
  pkg_is_installed${freebsd_pkg_suffix} "$@"
}

package_bootstrap() {
  pkg_bootstrap${freebsd_pkg_suffix} "$@"
}

pkg_bootstrap_is_package_available() {
  return 0
}
