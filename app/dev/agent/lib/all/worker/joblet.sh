_worker_run_joblet() {
  _worker_sandbox_init

  job_tries_remaining=$worker_agent_job_iterations

  if ! _worker_sandbox_run; then
    _worker_retry_failed_sandbox_run || {
      log_warn "sandbox run failed after retries — aborting joblet without committing"
      return 1
    }
  fi

  _worker_validate_job_output || {
    log_warn "job output validation failed — aborting joblet without committing"
    return 1
  }

  worker_sandbox_commit_${conf_agent_worker_environment}
  _worker_publish_artifacts
}
