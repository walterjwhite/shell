package_scoop_bootstrap() {
  command -v scoop >/dev/null 2>&1 && return 0

  log_info "installing scoop"
  curl -L https://get.scoop.sh | sh

  [ -f "$HOME/scoop/shims/scoop" ] && export PATH="$HOME/scoop/shims:$PATH"
}

package_scoop_bootstrap_uninstall() {
  log_info "uninstalling scoop"
  if command -v scoop >/dev/null 2>&1; then
    scoop uninstall scoop
    return
  fi

  log_warn "scoop is not installed"
}

package_scoop_install() {
  package_scoop_bootstrap

  log_info "installing package: $*"
  scoop install "$@"
}

package_scoop_uninstall() {
  log_info "uninstalling package: $*"
  scoop uninstall "$@"
}

package_scoop_update() {
  log_info "updating scoop and packages"
  scoop update
  scoop update *
}

package_scoop_is_installed() {
  local package_name=$1
  [ -z "$package_name" ] && return 1

  scoop list | grep -q "^$package_name$" 2>/dev/null
}
