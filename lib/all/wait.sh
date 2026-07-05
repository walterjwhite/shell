wait_waitee_init() {
  [ -z "$WAIT_WAITEE" ] && return

  processes_setup_app_pipe

  log_warn "please use -w=$$ ($APPLICATION_CMD)"

  exit_defer wait_waitee_done
}

wait_waitee_done() {
  [ -z "$WAIT_WAITEE" ] && return

  [ -e $application_pipe ] || return

  log_info "$0 process completed, notifying ($exit_status)"

  printf '%s\n' "$exit_status" >$application_pipe

  log_info "$0 downstream process picked up"
}

wait_waiter() {
  local _upstream_application_pipe
  local _upstream_application_status
  local _upstream_status

  [ -z "$wait_waiter_pid" ] && return

  _upstream_application_pipe=$(find $APPLICATION_CONTEXT_GROUP -type p -name $wait_waiter_pid 2>/dev/null | head -1)

  [ -z "$_upstream_application_pipe" ] && exit_with_error "$wait_waiter_pid not found"

  [ ! -e $_upstream_application_pipe ] && {
    log_warn "$_upstream_application_pipe does not exist, did upstream start?"
    return
  }

  log_info "waiting for upstream to complete: $wait_waiter_pid"

  while :; do
    if [ ! -e $_upstream_application_pipe ]; then
      exit_with_error "upstream pipe no longer exists"
    fi

    _upstream_application_status=$(time_timeout $conf_wait_interval "wait_waiter:upstream" cat $_upstream_application_pipe 2>/dev/null)

    _upstream_status=$?
    if [ $_upstream_status -eq 0 ]; then
      if [ -z "$_upstream_application_status" ] || [ $_upstream_application_status -gt 0 ]; then
        exit_with_error "upstream exited with exit_with_error ($_upstream_application_status)"
      fi

      log_warn "upstream finished: $_upstream_application_pipe ($_upstream_status)"
      break
    fi

    log_detail "upstream is still running: $_upstream_application_pipe ($_upstream_status)"
    sleep 1
  done
}
