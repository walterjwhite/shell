lib git/include.sh
lib ./git.sh

agent_extension_batch() {
  _extension_load_type

  local batch_opwd=$PWD
  local batch_dir
  for batch_dir in $(extension_find_dirs_containing); do
    cd $batch_dir
    _agent_extension "$@"

    cd $batch_opwd
  done
}

_agent_extension() {
  log_add_context "persona-$agent_persona"

  agent_job_git_repository=$(git remote -v | head -1 | awk {'print$2'})
  agent_project=$(basename $agent_job_git_repository | sed -e 's/\.git$//')
  agent_extension_type=$extension_run_type
  [ "$(git rev-parse --show-toplevel)" != "$(pwd)" ] && {
    agent_job_relative_path=$(_git_relative_path_in_worktree)
  }

  validation_require "$agent_job_git_repository" agent_job_git_repository

  _agent_extension_create_jobs
  _agent_extension_run_jobs

  log_remove_context
}

_agent_extension_run_jobs() {
  log_add_context run_jobs
  log_detail "$batch_dir | $PWD"
  for agent_job in $(find persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_relative_path -type d -name '*.job' | sort -V); do
    agent-worker $agent_job
  done
  log_remove_context
}
