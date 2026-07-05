service_install() {
  sudo_run service add "$@"
}

service_uninstall() {
  sudo_run service del "$@"
}

service_is_file() {
  return 1
}
