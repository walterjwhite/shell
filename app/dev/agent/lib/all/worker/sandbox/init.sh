lib git/archive.sh
lib io/file.sh

_worker_sandbox_init() {
  agent_job_work_path=$(realpath -m ./work)
  mkdir -p $agent_job_work_path

  [ -z "$agent_job_git_branch" ] && agent_job_git_branch=main

  _agent_get_job_name_key
  worker_sandbox_init_${conf_agent_worker_environment}
}

worker_sandbox_init_local() {
  if [ -e $agent_job_work_path/.git ]; then
    cd $agent_job_work_path
    git pull
  else
    git clone $agent_job_git_repository -b $agent_job_git_branch $agent_job_work_path
    cd $agent_job_work_path
  fi

  #
  #
  git checkout -b "$agent_job_name" 2>/dev/null || {
    log_warn "branch $agent_job_name already exists locally — reusing it"
    git checkout "$agent_job_name" || exit_with_error "unable to checkout branch: $agent_job_name"
  }
}
