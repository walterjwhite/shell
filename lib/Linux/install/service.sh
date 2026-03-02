service_install() {
  systemctl enable "$@"
}

service_uninstall() {
  systemctl disable "$@"
}
