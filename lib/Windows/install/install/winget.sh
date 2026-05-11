package_winget_bootstrap() {
  command -v winget >/dev/null 2>&1 && return 0

  log_info "checking winget availability"

  if command -v powershell >/dev/null 2>&1; then
    powershell -Command "Get-AppxPackage -Name 'Microsoft.DesktopAppInstaller' | Update-AppxPackage" 2>/dev/null || {
      log_warn "winget update failed, may need manual installation from Microsoft Store"
    }
  fi

  [ -d "$APP_PLATFORM_BIN_PATH" ] && export PATH="$APP_PLATFORM_BIN_PATH:$PATH"
}

package_winget_bootstrap_uninstall() {
  log_info "winget is built into Windows, cannot be uninstalled"
}

package_winget_install() {
  package_winget_bootstrap

  log_info "installing package: $*"
  winget install --accept-package-agreements --accept-source-agreements "$@"
}

package_winget_uninstall() {
  log_info "uninstalling package: $*"
  winget uninstall "$@"
}

package_winget_update() {
  log_info "updating winget and packages"
  winget upgrade --all --accept-package-agreements --accept-source-agreements
}

package_winget_is_installed() {
  local package_name=$1
  [ -z "$package_name" ] && return 1

  winget list --exact "$package_name" | grep -q "$package_name" 2>/dev/null
}
