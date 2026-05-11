package_chocolatey_bootstrap() {
  command -v choco >/dev/null 2>&1 && return 0

  log_info "installing chocolatey"
  if command -v powershell >/dev/null 2>&1; then
    powershell -Command "Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
  else
    if command -v curl >/dev/null 2>&1; then
      curl -L https://community.chocolatey.org/install.ps1 | powershell -Command -
    elif command -v wget >/dev/null 2>&1; then
      wget -qO- https://community.chocolatey.org/install.ps1 | powershell -Command -
    else
      exit_with_error "curl or wget required to install chocolatey"
    fi
  fi

  [ -d "$APP_PLATFORM_BIN_PATH" ] && export PATH="$APP_PLATFORM_BIN_PATH:$PATH"
}

package_chocolatey_bootstrap_uninstall() {
  log_info "uninstalling chocolatey"
  if command -v choco >/dev/null 2>&1; then
    log_warn "chocolatey must be manually uninstalled"
    return 1
  fi

  log_warn "chocolatey is not installed"
}

package_chocolatey_install() {
  package_chocolatey_bootstrap

  log_info "installing package: $*"
  choco install -y "$@"
}

package_chocolatey_uninstall() {
  log_info "uninstalling package: $*"
  choco uninstall -y "$@"
}

package_chocolatey_update() {
  log_info "updating chocolatey and packages"
  choco upgrade all -y
}

package_chocolatey_is_installed() {
  local package_name=$1
  [ -z "$package_name" ] && return 1

  choco list --local-only --exact "$package_name" | grep -q "$package_name" 2>/dev/null
}
