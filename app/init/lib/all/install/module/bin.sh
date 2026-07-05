bin_install() {
  mkdir -p "$TARGET_APP_PLATFORM_BIN_PATH"
  _install_files "$1" "$TARGET_APP_PLATFORM_BIN_PATH"
}

bin_uninstall() {
  [ ! -e "$1" ] && return

  while IFS= read -r _entry; do
    case "$_entry" in
    */) rm -rf "$_entry" ;;
    *) rm -f "$_entry" ;;
    esac
  done <"$1"
  rm -f "$1"
}

bin_is_installed() {
  :
}

bin_is_latest() {
  :
}
