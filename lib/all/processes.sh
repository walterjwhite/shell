processes_restrict_to_single_process() {
  _processes_has_other_instances && {
    exit_with_error "$APPLICATION_CMD is restricted to a single instance and another instance is running"
  }

  processes_setup_app_pipe
}

_processes_has_other_instances() {
  find $APPLICATION_CMD_DIR -maxdepth 1 -type p ! -name $$ 2>/dev/null | grep -qm1 '.'
}

processes_setup_app_pipe() {
  mkdir -p $APPLICATION_PIPE_DIR
  mkfifo $APPLICATION_PIPE

  exit_defer processes_cleanup_app_pipe
}

processes_cleanup_app_pipe() {
  rm -rf $APPLICATION_PIPE_DIR
}

_processes_kill_process_and_children() {
  kill -9 $(_processes_child_pids $1) 2>/dev/null
  kill -9 $1
}

_processes_child_pids() {
  validation_require "$1" "pid"
  pgrep -P $1
}
