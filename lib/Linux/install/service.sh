service_install() {
  _install_filter_file_callback $1 _systemctl_enable
}

_systemctl_enable() {
  systemctl enable --now "$@"
}

service_uninstall() {
  _install_filter_file_callback $1 _systemctl_disable
}

_systemctl_disable() {
  systemctl disable --now "$@"
}
