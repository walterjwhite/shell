lib io/file.sh
lib provider.sh

_worker_init_job() {
  cd $agent_job || exit_with_error "job not found: $agent_job"

  worker_agent_job_path=$PWD

  file_require ./job
  . ./job

  [ -z "$agent_worker" ] && {
    agent_worker=$(_worker_select_random_available_agent)
  }

  _worker_get_prompt

  log_set_logfile $worker_agent_job_path/log/$(date +%Y.%m.%d.%H.%M.%S)
  exit_defer _worker_cleanup

  validation_require "$agent_worker" agent_worker
  _provider_load $agent_worker

  validation_require "$worker_agent_prompt" worker_agent_prompt
  validation_require "$agent_job_git_repository" agent_job_git_repository

  log_detail 'job initialized'
}













_worker_sleep() {
  [ $worker_agent_job_work_iteration -eq 0 ] && return

  log_detail "sleeping $agent_job_iteration_delay"
  sleep $agent_job_iteration_delay
}
