lib system.sh

_agent_git_init_workspace() {
  [ ! -e $agent_workspace ] && {
    log_detail 'initializing workspace'
    system_id=$(_system_get_id)
    git clone $conf_agent_git_repository_prefix/$system_id/$USER/agent-work.git $agent_workspace
  }

  log_detail 'updating workspace'
  cd $agent_workspace
  gpull
}

_agent_git_update_job() {
  log_detail 'updating job status'

  mkdir -p $2
  agent_new_job_path=$(printf '%s' "$agent_job" | sed -e "s/$1/$2/")
  mkdir -p $(dirname $agent_new_job_path)
  git mv $agent_job $agent_new_job_path
  git commit $agent_job $agent_new_job_path -m "$agent_job_name - $2"
  gpush

  agent_job=$agent_new_job_path
}

_agent_get_job_name_key() {
  agent_job_name_key="${agent_job_name#[0-9][0-9].}"
  agent_job_name_key="${agent_job_name_key%.job}"
}
