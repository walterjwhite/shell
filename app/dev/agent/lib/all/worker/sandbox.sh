lib git/archive.sh
lib io/file.sh

_worker_sandbox_init() {
  agent_job_work_path=$(_file_readlink ./work)
  mkdir -p $agent_job_work_path

  [ -z "$agent_job_git_branch" ] && agent_job_git_branch=main

  _agent_get_job_name_key

  if [ -n "$agent_worker_container" ]; then
    _worker_sandbox_init_container
  else
    if [ -e $agent_job_work_path/.git ]; then
      cd $agent_job_work_path
      gpull
    else
      git clone $agent_job_git_repository -b $agent_job_git_branch $agent_job_work_path
      cd $agent_job_work_path
    fi
  fi
}

_worker_sandbox_run() {
  mkdir -p prompts
  cp $worker_agent_prompt prompts/$agent_job_name.md

  log_info "running $agent_worker: $job_tries_remaining"

  if [ -n "$agent_worker_container" ]; then
    _worker_sandbox_run_container
  else
    _worker_sandbox_run_locally
  fi
}

_worker_sandbox_run_locally() {
  log_info "running job locally"
  _agent_run
}

_worker_sandbox_commit() {
  [ -n "$agent_worker_container" ] && {
    _worker_sandbox_patch
    _worker_apply_patch
    return
  }

  cd $agent_job_work_path
  git add .
  git commit -am "$agent_worker - $agent_job_name_key"
  git push
}

_worker_rate_limit_wait() {
  log_warn "hit rate limit"

  local agent_backoff_epoch=$(_agent_rate_limit_wait)

  mkdir -p $APP_DATA_PATH
  printf '%s\n' $agent_backoff_epoch >$APP_DATA_PATH/$agent_worker.backoff

  local now=$(_time_current_time_unix_epoch)
  local delta=$(($agent_backoff_epoch - $now))

  if [ $delta -gt $conf_agent_rate_limit_wait_time ]; then
    log_warn "need to wait $delta before retrying > $conf_agent_rate_limit_wait_time"

    job_tries_remaining=0
  else
    log_warn "waiting $delta for rate limit to clear"
    sleep $delta

    rm -f $APP_DATA_PATH/$agent_worker.backoff
  fi
}
