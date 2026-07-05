rust_bootstrap() {
  _rust_bootstrap_is_rust_available || {
    _package_install_new_only $RUST_PACKAGE
    _rust_bootstrap_is_rust_available || rust_disabled=1
  }
}

_rust_bootstrap_is_rust_available() {
  command -v cargo >/dev/null 2>&1
}

_rust_root_dir() {
  printf '%s' "$TARGET_APP_PLATFORM_BIN_PATH" | sed -e 's/\/bin$//'
}

_rust_install_do() {
  _rust_is_installed $1 && {
    log_detail "$1 is already installed"
    return 0
  }

  cargo install --root=$(_rust_root_dir) "$@"
}

rust_update() {
  cargo update "$@"
}

_rust_uninstall_do() {
  cargo uninstall --root=$(_rust_root_dir) "$@"
}

_rust_is_installed() {
  cargo install --root=$(_rust_root_dir) --list | grep -cqm1 "^$1 .*:$"
}

rust_is_latest() {
  :
}
