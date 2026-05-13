package_bootstrap() {
  _package_manager_is_set || return 1

  package_${windows_package_manager}_bootstrap
}

_package_install_do() {
  _package_manager_is_set || return 1

  package_${windows_package_manager}_install "$@"
}

_package_uninstall_do() {
  _package_manager_is_set || return 1

  package_${windows_package_manager}_uninstall "$@"
}

package_bootstrap_uninstall() {
  _package_manager_is_set || return 1

  package_${windows_package_manager}_bootstrap_uninstall
}

package_update() {
  _package_manager_is_set || return 1

  package_${windows_package_manager}_update "$@"
}

_package_is_installed() {
  _package_manager_is_set || return 1

  package_${windows_package_manager}_is_installed "$@"
}

_package_manager_is_set() {
  [ -n "$windows_package_manager" ] && return

  log_warn "windows_package_manager is not set"
  return 1
}
