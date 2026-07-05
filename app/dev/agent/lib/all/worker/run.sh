_worker_run_job() {
  type _agent_job_batcher >/dev/null 2>&1 || {
    _worker_run_joblet
    local task_status=$? # capture BEFORE unset — unset always returns 0

    unset agent_job_task_type
    return $task_status
  }

  _worker_run_job_with_batcher
}

_worker_run_job_with_batcher() {
  log_add_context batch

  worker_agent_job_work_iteration=0
  for worker_agent_job_work_item in $(_agent_job_batcher); do
    log_add_context $worker_agent_job_work_item

    _worker_sleep_between_batch_iterations
    _worker_run_joblet

    worker_agent_job_work_iteration=$(($worker_agent_job_work_iteration + 1))

    log_remove_context
  done

  log_detail "ran $worker_agent_job_work_iteration batch iteration(s)"
  log_remove_context

  unset worker_agent_job_work_item worker_agent_job_work_iteration
}
