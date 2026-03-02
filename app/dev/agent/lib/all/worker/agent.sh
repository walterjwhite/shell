_worker_run_agent() {
  type _agent_job_batcher >/dev/null 2>&1 && {
    _worker_run_agent_batch _agent_job_batcher _agent_job_validation
    return
  }

  _worker_run_agent_joblet
}

_worker_run_agent_batch() {
  log_add_context batch

  _agent_add_path $worker_agent_job_work_path

  for worker_agent_job_work_item in $($1); do
    _worker_sandbox_init

    log_add_context $worker_agent_job_work_item

    _worker_sleep

    cd $worker_agent_job_work_path
    cd $worker_agent_job_work_item

    _worker_run_agent_joblet $2

    worker_agent_job_work_iteration=$(($worker_agent_job_work_iteration + 1))

    _worker_sandbox_patch
    
    log_remove_context
  done

  log_detail "ran $worker_agent_job_work_iteration batch iteration(s)"
  log_remove_context

  unset worker_agent_job_work_item
}

_worker_run_agent_joblet() {
  log_detail "running agent"

  export conf_log_console=$conf_log_console
  _agent_run || {
    _agent_is_rate_limit_error || {
      exit_with_error "error while running agent: $?"
    }

    log_warn "sleeping $agent_rate_limit_wait as a rate limit was hit"
    sleep $agent_rate_limit_wait
  }

  _job_validation_errors=0

  while [ $_job_validation_errors -le $worker_agent_job_iterations ]; do
    log_info 'running job validation'

    $1
    worker_agent_job_status=$?

    _worker_commit_work_log $worker_agent_job_work_path "validation - $worker_agent_job_status"
    [ $worker_agent_job_status -eq 0 ] && break

    _job_validation_errors=$(($_job_validation_errors + 1))

    _worker_sleep

    log_warn "attempting to resolve error"
    local original_prompt=$worker_agent_prompt
    worker_agent_prompt=$worker_agent_job_path/prompt-error-$(date +%s)

    printf 'Attempt to resolve the following error (the snippet below is only the last %s lines of the log, the full log is located @ %s):\n' $agent_validation_error_context_lines $log_logfile >$worker_agent_prompt
    tail -${agent_validation_error_context_lines} $log_logfile >>$worker_agent_prompt
    worker_agent_prompt=$(_file_readlink $worker_agent_prompt)

    _agent_run

    worker_agent_prompt=$original_prompt
  done

  cd $worker_agent_job_path

  if [ "$conf_log_level" -gt 0 ]; then
    log_info "dropping work dir"
    rm -rf work
  else
    log_warn "preserving work dir"
  fi
}
