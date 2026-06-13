_worker_run_job_joblet() {
  _worker_sandbox_init

  local job_tries_remaining=$worker_agent_job_iterations
  _worker_sandbox_run || _worker_fix_error

  _worker_run_job_validation

  _worker_sandbox_commit
  _worker_publish_artifacts
}

_worker_fix_error() {
  log_warn "attempting to resolve error"
  local original_prompt=$worker_agent_prompt

  while [ $job_tries_remaining -gt 0 ]; do
    job_tries_remaining=$(($job_tries_remaining - 1))
    if _agent_is_rate_limit_error; then
      _worker_rate_limit_wait
    else
      worker_agent_prompt=$worker_agent_job_path/prompt-error-$(date +%s)
      printf 'Attempt to resolve the following error (the snippet below is only the last %s lines of the log, the full log is located @ %s):\n' \
        $agent_validation_error_context_lines $log_logfile >$worker_agent_prompt

      tail -${agent_validation_error_context_lines} $log_logfile >>$worker_agent_prompt
      worker_agent_prompt=$(_file_readlink $worker_agent_prompt)
    fi

    _worker_sandbox_run && break
  done

  _agent_commit_work_log . "fix error"

  worker_agent_prompt=$original_prompt
}

_worker_run_job_validation() {
  [ -n "$agent_job_task_type" ] && type agent_job_validation_${agent_job_task_type} >/dev/null 2>&1 && {
    log_info "running job validation ($agent_job_task_type)"
    agent_job_validation_${agent_job_task_type}
  }

  type _agent_job_validation >/dev/null 2>&1 && {
    log_info "running _agent_job_validation"

    _agent_job_validation || _worker_fix_error
    return
  }
}

agent_job_validation_coding() {
  log_info "running format"
  format >>$log_logfile 2>&1 || _worker_fix_error

  log_info "running build"
  build >>$log_logfile 2>&1 || _worker_fix_error

  log_info "running tests"
  tests >>$log_logfile 2>&1 || _worker_fix_error
}

agent_job_validation_documentation() {
  [ -z "$agent_documentation_path" ] && return 0

  find . -type f -path "*/$agent_documentation_path/*.md" -print -quit | grep -cqm1 '.'
}
