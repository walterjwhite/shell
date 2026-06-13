_agent_run_remotely() {
  _agent_is_remote || return 1

  log_warn "remote host defined, running $APPLICATION_CMD on remote host: $remote_host"
  ssh $remote_host "add_log_context=$remote_host-remote $APPLICATION_CMD $*"
  remote_exit_status=$?

  return 0
}

_agent_is_remote() {
  [ -z "$remote_host" ] && return 1

  [ "$remote_host" != "$(hostname)" ]
}
