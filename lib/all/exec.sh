exec_call() {
  local _function_name=$1

  type $_function_name >/dev/null 2>&1 || {
    log_debug "${_function_name} does not exist"

    return 255
  }

  [ $# -gt 1 ] && {
    shift
    $_function_name "$@"
    return $?
  }

  $_function_name
}

exec_wrap() {
  if [ -n "$exec_attempts" ]; then
    local _attempt=1

    while [ $_attempt -le $exec_attempts ]; do
      [ $_attempt -gt 1 ] && [ -n "$exec_delay" ] && sleep $exec_delay

      warn_on_error=1 _exec_do_exec "$@" && return

      _attempt=$(($_attempt + 1))
    done

    exit_with_error "failed after $_attempt attempts: $*"
  fi

  _exec_do_exec "$@"
}

_exec_do_exec() {
  local _successful_exit_status=0
  if [ -n "$successful_exit_status" ]; then
    _successful_exit_status=$successful_exit_status

    unset successful_exit_status
  fi

  log_info "$*"
  local _exit_status
  if [ -z "$dry_run" ]; then
    "$@"
    _exit_status=$?
  else
    log_warn "using dry run status: $dry_run"
    _exit_status=$dry_run
  fi

  if [ $_exit_status -ne $_successful_exit_status ]; then
    if [ -n "$on_failure" ]; then
      $on_failure
      return
    fi

    if [ -z "$warn_on_error" ]; then
      exit_with_error "previous cmd failed: $* - $_exit_status"
    else
      unset warn_on_error
      log_warn "previous cmd failed: $* - $_exit_status"
      environment_file=$(_mktemp_mktemp error) _environment_dump

      return $_exit_status
    fi
  fi
}
