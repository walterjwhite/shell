lib install/go.sh

go_install() {
  go_bootstrap
  _install_filter_file_callback $1 _go_install_do
}

go_update() {
  :
}

go_uninstall() {
  _install_uninstall_filter_file_callback $1 _go_uninstall_do
}

go_is_installed() {
  _setup_type_is_installed "$1"
}
