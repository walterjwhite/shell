run_install() {
  . "$1"
}

run_uninstall() {
  [ ! -e "$1" ] && return

  while IFS= read -r _entry; do
    case "$_entry" in
    */) rm -rf "$_entry" ;;
    *) rm -f "$_entry" ;;
    esac
  done <"$1"
  rm -f "$1"
}

run_is_installed() {
  :
}

run_is_latest() {
  :
}
