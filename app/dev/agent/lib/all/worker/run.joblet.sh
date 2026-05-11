_worker_run_job_joblet() {
  _worker_sandbox_init
  _worker_sandbox_run || _worker_fix_error
  _worker_run_job_validation

  _worker_sandbox_patch && _worker_apply_patch

  _worker_publish_artifacts
}

_worker_fix_error() {
  log_warn "attempting to resolve error"

  local job_tries_remaining=$worker_agent_job_iterations
  local original_prompt=$worker_agent_prompt

  while [ $job_tries_remaining -gt 0 ]; do
    worker_agent_prompt=$worker_agent_job_path/prompt-error-$(date +%s)
    printf 'Attempt to resolve the following error (the snippet below is only the last %s lines of the log, the full log is located @ %s):\n' $agent_validation_error_context_lines $log_logfile >$worker_agent_prompt
    tail -${agent_validation_error_context_lines} $_worker_job_logfile >>$worker_agent_prompt
    worker_agent_prompt=$(_file_readlink $worker_agent_prompt)

    _worker_commit_work_log $worker_agent_job_work_path "fix error"

    _worker_sandbox_run
  done

  worker_agent_prompt=$original_prompt
}

_worker_run_job_validation() {
  [ -n "$agent_job_is_coding_task" ] && {
    log_info "running format"
    format >>$_worker_job_logfile 2>&1 || _worker_fix_error

    log_info "running build"
    build >>$_worker_job_logfile 2>&1 || _worker_fix_error

  }

  type _agent_job_validation >/dev/null 2>&1 && {
    log_info "running _agent_job_validation"

    _agent_job_validation || _worker_fix_error
    return
  }

  log_info 'running job validation'
  _agent_validate_documentation
}
