_agent_git_init_workspace() {
  [ ! -e $agent_workspace ] && {
    log_detail 'initializing workspace'
    system_id=$(_system_get_id)
    git clone $conf_agent_git_repository_prefix/$system_id/$USER/agent-work.git $agent_workspace
  }

  log_detail 'updating workspace'
  cd $agent_workspace
  git pull
}
