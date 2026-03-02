pypi_install() {
  _install_filter_file_callback $1 _pypi_install_do
}

pypi_uninstall() {
  _install_uninstall_filter_file_callback $1 _pypi_uninstall_do
}

pypi_is_installed() {
  _setup_type_is_installed "$1"
}
