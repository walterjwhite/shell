rust_install() {
  _install_filter_file_callback $1 _rust_install_do
}

rust_uninstall() {
  _install_uninstall_filter_file_callback $1 _rust_uninstall_do
}
