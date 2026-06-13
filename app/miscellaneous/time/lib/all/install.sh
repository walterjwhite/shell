_time_install() {
  local _source_filename=$(basename $1)

  file_require "$1"

  local _target_path=$_APP_DATA_PATH/$target_application_name

  mkdir -p $_target_path

  local _target_job_filename=$_target_path/$_source_filename

  if [ -e $_target_job_filename ]; then
    log_warn "killing any existing processes for $_target_job_filename"

    local _running_processes=$(ps | grep $_source_filename | grep -v grep | awk {'print$1'})
    if [ -n "$_running_processes" ]; then
      log_warn "found $_running_processes, killing"
      kill $_running_processes
    else
      log_warn "no running processes found for $_source_filename"
    fi
  fi

  cp $1 $_target_job_filename

  $_target_job_filename &
  >/dev/null 2>&1

  log_info "started $_source_filename $!"
}
