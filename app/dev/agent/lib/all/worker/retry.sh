_worker_retry_failed_sandbox_run() {
  log_warn "attempting to resolve error"
  local original_prompt=$worker_agent_prompt
  local _retry_succeeded=0

  while [ $job_tries_remaining -gt 0 ]; do
    job_tries_remaining=$(($job_tries_remaining - 1))
    _worker_prepare_sandbox_retry

    if _worker_sandbox_run; then
      _retry_succeeded=1
      break
    fi
  done

  [ "$_retry_succeeded" -eq 0 ] && worker_agent_prompt=$original_prompt

  [ "$_retry_succeeded" -eq 1 ]
}

_worker_prepare_sandbox_retry() {
  if _agent_is_rate_limit_error; then
    _worker_wait_for_agent_rate_limit
    return
  fi

  _worker_create_error_retry_prompt
}

_worker_create_error_retry_prompt() {
  worker_agent_prompt=$worker_agent_job_path/prompt-error-$(date +%s)
  printf 'Attempt to resolve the following error (the snippet below is only the last %s lines of the log, the full log is located @ %s):\n' \
    $agent_validation_error_context_lines $log_logfile >$worker_agent_prompt

  tail -${agent_validation_error_context_lines} $log_logfile >>$worker_agent_prompt
  worker_agent_prompt=$(realpath -m $worker_agent_prompt)

  git add $worker_agent_prompt
}
