lib io/file.sh
lib provider.sh

_worker_init_job() {
  cd $agent_workspace

  file_require $agent_job
  cd $agent_job

  worker_agent_job_path=$PWD

  file_require ./job
  . ./job
  validation_require "$agent_job_git_repository" agent_job_git_repository

  [ -z "$agent_worker" ] && {
    agent_worker=$(_worker_select_random_available_agent)
  }

  validation_require "$agent_worker" agent_worker
  _provider_load $agent_worker

  file_require ./prompt.md
  worker_agent_prompt=$(realpath -m ./prompt.md)
  validation_require "$worker_agent_prompt" worker_agent_prompt

  _log_set_logfile $worker_agent_job_path/log/$(date +%Y.%m.%d.%H.%M.%S)

  exit_defer _worker_cleanup

  log_detail 'job initialized'
}

_worker_sleep_between_batch_iterations() {
  [ $worker_agent_job_work_iteration -le 0 ] && return

  log_detail "sleeping $agent_job_iteration_delay"
  sleep $agent_job_iteration_delay
}
