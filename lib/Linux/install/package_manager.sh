_package_install_do() {
  package_${linux_package_manager}_install_do "$@"
}


_package_uninstall_do() {
  package_${linux_package_manager}_uninstall_do "$@"
}


_package_is_installed() {
  package_${linux_package_manager}_is_installed "$@"
}

package_bootstrap() {
  package_${linux_package_manager}_bootstrap "$@"
}

package_update() {
  log_detail "updating packages via ${linux_package_manager}"
  package_${linux_package_manager}_update "$@"
}
