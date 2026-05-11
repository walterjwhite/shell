package_scoop_bootstrap() {
  [ -n "$scoop_disabled" ] && {
    log_warn "scoop is disabled"
    return 1
  }

  command -v scoop >/dev/null 2>&1 && return 0

  log_info "installing scoop"
  curl -L https://get.scoop.sh | sh

  [ -f "$HOME/scoop/shims/scoop" ] && export PATH="$HOME/scoop/shims:$PATH"
}

package_scoop_bootstrap_uninstall() {
  [ -n "$scoop_disabled" ] && {
    log_warn "scoop is disabled"
    return 1
  }

  log_info "uninstalling scoop"
  if command -v scoop >/dev/null 2>&1; then
    scoop uninstall scoop
    return
  fi

  log_warn "scoop is not installed"
}

package_scoop_install() {
  [ -n "$scoop_disabled" ] && {
    log_warn "scoop is disabled"
    return 1
  }
  
  package_scoop_bootstrap

  log_info "installing package: $*"
  scoop install "$@"
}

package_scoop_uninstall() {
  [ -n "$scoop_disabled" ] && {
    log_warn "scoop is disabled"
    return 1
  }
  
  log_info "uninstalling package: $*"
  scoop uninstall "$@"
}

package_scoop_update() {
  [ -n "$scoop_disabled" ] && {
    log_warn "scoop is disabled"
    return 1
  }
  
  log_info "updating scoop and packages"
  scoop update
  scoop update *
}

package_scoop_is_installed() {
  [ -n "$scoop_disabled" ] && {
    log_warn "scoop is disabled"
    return 1
  }
  
  local package_name=$1
  [ -z "$package_name" ] && return 1

  scoop list | grep -q "^$package_name$" 2>/dev/null
}
