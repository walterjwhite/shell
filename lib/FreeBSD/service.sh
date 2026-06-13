service_disable_service() {
  local _service_action=stop
  local _service_enabled=NO
  _service_service "$@"
}

service_enable_service() {
  local _service_action=start
  local _service_enabled=YES
  _service_service "$@"
}

_service_service() {
  local _service
  for _service in "$@"; do
    [ -z "$os_installer_chroot" ] && {
      service "$_service" "one${_service_action}"
    }

    sysrc "${_service}_enable=${_service_enabled}"
  done
}
