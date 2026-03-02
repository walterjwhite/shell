service_install() {
  service add "$@"
}

service_uninstall() {
  service del "$@"
}

service_is_file() {
  return 1
}
