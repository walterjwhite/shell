npm_install() {
  npm_bootstrap

  _install_filter_file_callback $1 _npm_install_do
}

npm_uninstall() {
  npm_bootstrap

  _install_uninstall_filter_file_callback $1 _npm_uninstall_do
}

npm_is_installed() {
  :
}

npm_is_latest() {
  :
}
