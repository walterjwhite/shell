_worker_validate_job_output() {
  _worker_run_task_type_validation || return 1
  _worker_run_job_file_validation || return 1
}

_worker_run_task_type_validation() {
  [ -n "$agent_job_task_type" ] || return 0
  type agent_job_validation_${agent_job_task_type} >/dev/null 2>&1 || return 0

  log_info "running job validation ($agent_job_task_type)"
  agent_job_validation_${agent_job_task_type}
}

_worker_run_job_file_validation() {
  type _agent_job_validation >/dev/null 2>&1 || return 0

  log_info "running _agent_job_validation"

  if ! _agent_job_validation; then
    _worker_retry_failed_sandbox_run || return 1
    _agent_job_validation || return 1
  fi
}

agent_job_validation_coding() {
  log_info "running format"
  if ! format >>$log_logfile 2>&1; then
    _worker_retry_failed_sandbox_run || {
      log_warn "format failed and retry exhausted — aborting coding validation"
      return 1
    }
  fi

  git commit -am 'formatted'
  git push -u

  log_info "running build"
  if ! build >>$log_logfile 2>&1; then
    _worker_retry_failed_sandbox_run || {
      log_warn "build failed and retry exhausted — aborting coding validation"
      return 1
    }
  fi

  git commit -am 'built'
  git push -u

}

agent_job_validation_documentation() {
  [ -z "$agent_documentation_path" ] && return 0

  find . -type f -path "*/$agent_documentation_path/*.md" -print -quit | grep -cqm1 '.'
}
