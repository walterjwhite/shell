lib install/module/utils_Gentoo.sh

package_accept_keywords_bootstrap() {
  :
}

package_accept_keywords_install() {
  _utils_portage_install_file package.accept_keywords $1
}

package_accept_keywords_uninstall() {
  _utils_portage_uninstall_file package.accept_keywords $1
}

package_accept_keywords_is_installed() {
  _utils_portage_is_installed package.accept_keywords $1
}

package_accept_keywords_enabled() {
  return 0
}

package_accept_keywords_is_file() {
  return 0
}
