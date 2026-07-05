_driver_run_job() {
  cd $agent_workspace

  agent_job_name=$(basename $agent_job)
  log_add_context $agent_job_name

  cd $agent_job

  _driver_is_job_runnable || {
    local _runnable_status=$? # capture BEFORE log_remove_context overwrites $?
    log_remove_context
    return $_runnable_status
  }

  agent-worker $agent_job

  _driver_record_job_run

  log_info "completed"
  log_remove_context

  cd $agent_workspace
}

_driver_is_job_runnable() {
  [ -e .run ] && {
    [ -z "$driver_is_scheduled_job" ] && {
      log_warn "job already run"
      return 1
    }

    _driver_is_scheduled_job_due || return $?
  }

  _driver_is_job_running && {
    log_warn "job is already running"
    return 2
  }

  [ -z "$driver_is_scheduled_job" ] && [ -e schedule ] && {
    log_warn "job is a scheduled job"
    driver_scheduled_job_count=$(($driver_scheduled_job_count + 1))
    return 3
  }

  return 0
}

_driver_is_scheduled_job_due() {
  case $agent_job_schedule in
  daily)
    _driver_has_elapsed_since_last_run 86400 daily 4 || return $?
    ;;
  weekly)
    _driver_has_elapsed_since_last_run 604800 weekly 5 || return $?
    ;;
  monthly)
    _driver_has_elapsed_since_last_run 18144000 monthly 6 || return $?
    ;;
  esac
}

_driver_has_elapsed_since_last_run() {
  local expected_delta=$1
  local run_interval=$2
  local fail_status=$3

  local last_run_time=$(head -1 .run)
  local current_time=$(date +%s)
  local delta=$(($current_time - $last_run_time))
  [ $delta -lt $expected_delta ] && {
    log_warn "scheduled to run $run_interval and delta is: $delta - skipping"
    return $fail_status
  }

  return 0
}

_driver_record_job_run() {
  date +%s >.run

  git add .run
  git commit .run -m "ran $agent_job_name"
  git push
}

_driver_is_scheduled_job_runnable() {
  _driver_is_scheduled_job_due
}

_driver_has_enough_time_elapsed_since_last_run() {
  _driver_has_elapsed_since_last_run "$@"
}
