lib extension.sh


_run_application_runner() {
  extension_action=run
  extension_run_type_path="__LIBRARY_PATH__/install/extensions/extension/$extension_action/$extension_run_type"
  extension_feature_name=${extension_action}_${extension_run_type}
  extension_feature_name=$(printf '%s' $extension_feature_name)
  . $extension_run_type_path/run.sh

  log_info "running $extension_run_type"

  _env_init
  _run_init_secrets

  [ "$_DISPLAY_ENV" ] && {
    log_warn "displaying all secrets and env vars"
    _env_display
    exit 0
  }

  _run_main "$@"
}

_run_main() {
  exit_defer _run_cleanup

  exec_call _runner_init "$@"
  exec_call _application_init "$@"
  exec_call _runner_run "$@" || log_warn "run failed: $?"

  [ -z "$_DEV_NOTAIL" ] && {
    _colored_tail_show &
    _run_tail_pid=$!
  }

  _run_notify_running
  _run_wait_for

  [ -n "$_DEV_OPEN_LOG" ] && _run_file_open_log
}

_run_cleanup() {
  log_info "run cleaning up"
  [ -n "$_run_tail_pid" ] && _processes_kill_process_and_children "$_run_tail_pid" 2>/dev/null
  [ -n "$_run_notify_pid" ] && _processes_kill_process_and_children "$_run_notify_pid" 2>/dev/null

  _run_graceful_shutdown

  [ -n "$_run_instance_dir" ] && rm -rf "$_run_instance_dir"

  exec_call "_${extension_run_type}_cleanup"
}

_run_graceful_shutdown() {
  local _exited=1
  log_detail "waiting up to ${_RUN_SHUTDOWN_TIMEOUT}s for $run_pid to exit"
  for i in $(seq 1 "$_RUN_SHUTDOWN_TIMEOUT"); do
    kill "$run_pid" 2>/dev/null

    log_print_to_console '.'
    sleep 1

    ps -p "$run_pid" >/dev/null 2>&1 || {
      log_print_newline_to_console
      log_detail "process $run_pid has exited."
      _exited=0

      break
    }
  done

  log_print_newline_to_console
  [ $_exited -eq 1 ] && kill -9 "$run_pid" 2>/dev/null
}

_run_notify_running() {
  [ -z "$_NOTIFY" ] && return 1
  processes_setup_app_pipe

  exec_call "_${extension_run_type}_is_running"


  printf '%s\n' "started" >"$APPLICATION_PIPE" &
  _run_notify_pid=$!
}

_run_wait_for() {
  [ -z "$run_pid" ] && return 1

  ps -p "$run_pid" >/dev/null 2>&1
  wait "$run_pid"
}
