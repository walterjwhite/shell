_software_center_install() {
  _software_center_run install $@
}

_software_center_update() {
  _software_center_run update $@
}

_software_center_is_disabled() {
  [ -n "$software_center_disabled" ] && return 0

  return 1
}

_software_center_run() {
  _software_center_is_disabled && return

  $SOFTWARE_CENTER_EXECUTABLE $1 $2

  local _install_status=$?
  [ "$_install_status" -gt 0 ] && log_warn "disabling software center installer: $_install_status"
}

_software_center_bootstrap() {
  exit_with_error "software center bootstrap is not yet implemented"
}

_software_center_is_installed() {
  [ -e "$SOFTWARE_CENTER_EXECUTABLE" ] && return 0

  return 1
}
