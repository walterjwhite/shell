_worker_sandbox_run() {

  log_info "running $agent_worker: $job_tries_remaining ($conf_agent_worker_environment)"
  set >>$log_logfile

  worker_sandbox_run_${conf_agent_worker_environment}
}

worker_sandbox_run_local() {
  log_info "running job locally"
  _agent_run
}
