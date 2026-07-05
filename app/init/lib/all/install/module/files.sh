files_install() {
  case $INSTALL_TARGET in
  SYSTEM)
    ;;
  *)
    [ -e "$1/_ROOT_" ] && exit_with_error "unable to install files @ root for a user install"
    ;;
  esac

  _install_files "$1/_ROOT_" "$APP_PLATFORM_ROOT"
  _install_files "$1/_APPLICATION_ROOT_" "$TARGET_APP_PATH"

  return 0
}

files_uninstall() {
  [ ! -e "$1" ] && return 0

  while IFS= read -r _entry; do
    case "$_entry" in
    */) rm -rf "$_entry" ;;
    *) rm -f "$_entry" ;;
    esac
  done <"$1"
  rm -f "$1"
}

files_is_installed() {
  :
}

files_is_latest() {
  :
}
