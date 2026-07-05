sbin_install() {
  [ -z "$TARGET_APP_PLATFORM_SBIN_PATH" ] && {
    log_warn "$TARGET_APP_PLATFORM_SBIN_PATH is unset, skipping"
    return 1
  }

  mkdir -p "$TARGET_APP_PLATFORM_SBIN_PATH"
  _install_files "$1" "$TARGET_APP_PLATFORM_SBIN_PATH"
}

sbin_uninstall() {
  [ ! -e "$1" ] && return

  while IFS= read -r _entry; do
    case "$_entry" in
    */) rm -rf "$_entry" ;;
    *) rm -f "$_entry" ;;
    esac
  done <"$1"
  rm -f "$1"
}

sbin_is_installed() {
  :
}

sbin_is_latest() {
  :
}
