_platform_xcode_bootstrap() {
  xcode-select -p >/dev/null 2>&1 || {
    log_warn "xcode does not appear to be installed, installing"
    sudo xcode-select --install
  }
}
