package_bootstrap() {
  package_${windows_package_manager}_bootstrap
}

_package_install_do() {
  package_${windows_package_manager}_install "$@"
}

_package_uninstall_do() {
  package_${windows_package_manager}_uninstall "$@"
}

package_bootstrap_uninstall() {
  package_${windows_package_manager}_bootstrap_uninstall
}

package_update() {
  package_${windows_package_manager}_update "$@"
}

_package_is_installed() {
  package_${windows_package_manager}_is_installed "$@"
}
