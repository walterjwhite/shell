rust_bootstrap() {
  _rust_bootstrap_is_rust_available || {
    _package_install_new_only $RUST_PACKAGE
    _rust_bootstrap_is_rust_available || rust_disabled=1
  }
}

_rust_bootstrap_is_rust_available() {
  which cargo >/dev/null 2>&1
}

_rust_install_do() {
  _rust_is_installed $1 && {
    log_detail "$1 is already installed"
    return 0
  }
  
  local _rust_root_dir=$(printf '%s' $APP_PLATFORM_BIN_PATH | sed -e 's/\/bin//')
  cargo install --root=$_rust_root_dir "$@"
}

rust_update() {
  cargo update "$@"
}

_rust_uninstall_do() {
  local _rust_root_dir=$(printf '%s' $APP_PLATFORM_BIN_PATH | sed -e 's/\/bin//')
  cargo uninstall --root=$_rust_root_dir "$@"
}

_rust_is_installed() {

  local _rust_root_dir=$(printf '%s' $APP_PLATFORM_BIN_PATH | sed -e 's/\/bin//')
  cargo install --root=$_rust_root_dir --list | $GNU_GREP -Pcqm1 "^$1 .*:$"
}

rust_is_latest() {
  :
}
