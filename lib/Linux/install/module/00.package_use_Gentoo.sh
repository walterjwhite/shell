lib install/module/utils_Gentoo.sh

package_use_bootstrap() {
  :
}

package_use_install() {
  _utils_portage_install_file package.use $1
}

package_use_uninstall() {
  _utils_portage_uninstall_file package.use $1
}

package_use_is_installed() {
  _utils_portage_is_installed package.use $1
}

package_use_enabled() {
  return 0
}

package_use_is_file() {
  return 0
}
