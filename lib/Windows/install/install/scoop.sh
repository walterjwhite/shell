_scoop_install() {
  scoop install $@
}

_scoop_update() {
  scoop update $@
}

_scoop_bootstrap() {
  exit_with_error "scoop bootstrap is not yet implemented"
}

_scoop_is_installed() {
  which scoop >/dev/null 2>&1
}
