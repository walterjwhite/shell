lib install/module/utils_Gentoo.sh

package_license_bootstrap() {
  :
}

package_license_install() {
  _utils_portage_install_file package.license $1
}

package_license_uninstall() {
  _utils_portage_uninstall_file package.license $1
}

package_license_is_installed() {
  _utils_portage_is_installed package.license $1
}

package_license_enabled() {
  return 0
}

package_license_is_file() {
  return 0
}
