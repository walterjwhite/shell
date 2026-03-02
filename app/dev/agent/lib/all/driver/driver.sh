lib io/file.sh

_driver_run_all_jobs() {
  log_info "running all jobs"

  for agent_job in $(find . -type d -name '*.job' ! -path '*/.*/*' | sort -V); do
    _driver_run_job
  done

  [ -z "$driver_scheduled_job_count" ] && return

  log_warn "has $driver_scheduled_job_count scheduled jobs"
  _driver_wait_for_scheduled_job_window
  _driver_run_scheduled_jobs
}

_driver_run_specified_jobs() {
  log_info "processing $*"

  for agent_job in "$@"; do
    [ ! -e $agent_job ] && exit_with_error "$agent_job does not exist"

    _driver_run_job
  done
}

_driver_is_job_running() {
  pgrep -f "agent-worker $agent_job" >/dev/null 2>&1
}

_driver_wait_for_scheduled_job_window() {
  when-at $conf_agent_scheduled_jobs_window_start_time echo
}

_driver_run_scheduled_jobs() {
  driver_is_scheduled_job=1
  for agent_job in $(find . -type f -path '*/*.job/schedule' ! -path '*/.*/*' -execdir pwd \; | sort -V); do
    agent_job_schedule=$(head -1 schedule)

    _driver_run_job
  done
}
