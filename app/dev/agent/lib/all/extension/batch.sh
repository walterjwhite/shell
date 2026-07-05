lib git/include.sh
lib ./git.sh

agent_extension_batch() {
  log_add_context "persona-$agent_persona"

  _extension_load_type

  agent_invocation_wd=$PWD
  _agent_git_init_workspace
  for agent_persona_job in $(find $APP_PATH/personas/$agent_persona -maxdepth 1 -mindepth 1 -type d | sort -V); do
    agent_job_name=$(basename $agent_persona_job)

    _agent_get_job_name_key

    log_add_context $agent_job_name_key

    _agent_extension_create_workspace_jobs_for_persona_job
    _agent_extension_run_workspace_jobs

    log_remove_context
  done

  log_remove_context
}
