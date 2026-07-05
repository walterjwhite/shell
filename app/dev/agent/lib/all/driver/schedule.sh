_driver_wait_for_scheduled_job_window() {
  when-at $conf_agent_scheduled_jobs_window_start_time echo
}

_driver_run_scheduled_jobs() {
  driver_is_scheduled_job=1
  for agent_job in $(find . -type f -path '*/*.job/schedule' ! -path '*/.*/*' -execdir pwd \; | sort -V); do
    agent_job_schedule=$(head -1 "$agent_job/schedule")

    _driver_run_job
  done
  unset driver_is_scheduled_job
}
