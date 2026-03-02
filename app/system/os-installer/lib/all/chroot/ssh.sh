lib ./bootstrap/service.sh

_start_ssh() {
  _net_is_port_in_use 22
  if [ $? -eq 0 ]; then
    log_warn "unable to start SSHd as it is already running"
  else
    _start_service sshd
    local _sshd_started=1
  fi

  log_warn "iP: $(_net_ips)"
}

_stop_ssh() {
  [ -z "$_sshd_started" ] && return 1

  _stop_service sshd
}
