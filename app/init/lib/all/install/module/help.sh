help_install() {
  _install_files "$1" "$TARGET_APP_PATH/help"
}

help_uninstall() {
  [ ! -e "$1" ] && return

  while IFS= read -r _entry; do
    case "$_entry" in
    */) rm -rf "$_entry" ;;
    *) rm -f "$_entry" ;;
    esac
  done <"$1"
  rm -f "$1"
}
