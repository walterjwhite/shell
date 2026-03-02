_agent_extension_create_jobs() {
  log_add_context create_jobs
  _agent_git_init_workspace
  for agent_persona_job in $(find __LIBRARY_PATH__/__APPLICATION_NAME__/personas/$agent_persona -maxdepth 1 -mindepth 1 -type d | sort -V); do
    _agent_extension_create_job
  done

  git add persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_relative_path
  git commit -m "created jobs for $agent_persona - $agent_project"
  git push

  log_remove_context
}

_agent_extension_create_job() {
  agent_job_name=$(basename $agent_persona_job)

  log_add_context $agent_job_name
  log_detail "creating job"

  mkdir -p persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_relative_path/$agent_job_name
  cp $agent_persona_job/prompt.md persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_relative_path/$agent_job_name/

  (
    printf 'agent_job_git_repository=%s\n' "$agent_job_git_repository"
    printf 'agent_extension_type=%s\n' "$agent_extension_type"
  ) >persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_relative_path/$agent_job_name/job

  [ -n "$agent_job_relative_path" ] && {
    log_warn "batch"

    (
      printf "_agent_job_batcher() {\n"
      printf "  printf '%s\\\n'\n" $agent_job_relative_path
      printf '}\n'
    ) >>persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_relative_path/$agent_job_name/job
  }

  log_remove_context
}
