extensions_install() {
  _install_extension_cmds "$1"
  _install_extension_extensions "$1" "$installed_files"
}

_install_extension_cmds() {
  [ ! -e "$1/bin" ] && return

  log_detail "installing extension $1/bin"
  _install_files "$1/bin" "$TARGET_APP_PLATFORM_BIN_PATH"
}

_install_extension_extensions() {
  [ -e "$1/extension" ] && {
    log_detail "installing extension $1/extension"
    _install_files "$1/extension" "$TARGET_APP_PLATFORM_EXTENSIONS_PATH/extension"
  }

  [ -e "$1/type" ] && {
    log_detail "installing extension $1/type"
    _install_files "$1/type" "$TARGET_APP_PLATFORM_EXTENSIONS_PATH/type"
  }

  return 0
}

extensions_uninstall() {
  [ ! -e "$1" ] && return

  while IFS= read -r _entry; do
    case "$_entry" in
    */) rm -rf "$_entry" ;;
    *) rm -f "$_entry" ;;
    esac
  done <"$1"
  rm -f "$1"
}

extensions_is_installed() {
  :
}

extensions_is_latest() {
  :
}
