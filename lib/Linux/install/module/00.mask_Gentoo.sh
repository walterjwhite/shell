lib install/module/utils_Gentoo.sh

mask_bootstrap() {
  :
}

mask_install() {
  _utils_portage_install_file package.mask $1
}

mask_uninstall() {
  _utils_portage_uninstall_file package.mask $1
}

mask_is_installed() {
  _utils_portage_is_installed package.mask $1
}

mask_enabled() {
  return 0
}

mask_is_file() {
  return 0
}
