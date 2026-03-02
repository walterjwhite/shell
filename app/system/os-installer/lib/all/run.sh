_run_run() {
  log_info "$*"

  local run_file=${_os_installer_exec_dir}/$1
  [ -e $run_file ] && {
    log_warn "$* already run, skipping"
    return
  }

  mkdir -p ${_os_installer_exec_dir}
  touch $run_file
  "$@"
}
