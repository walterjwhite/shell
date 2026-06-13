lib io/file.sh

_agent_extension_create_job() {
  agent_job_git_repository=$(git remote -v | head -1 | awk {'print$2'})
  agent_project=$(basename $agent_job_git_repository | sed -e 's/\.git$//')
  agent_extension_type=$extension_run_type


  validation_require "$agent_job_git_repository" agent_job_git_repository

  log_add_context $agent_job_relative_path

  _agent_load_job_cfg

  [ -n "$agent_persona_job_disabled" ] && {
    _agent_log_persona_job_no_run "disabled"
    log_remove_context
    return 1
  }

  _agent_write_job
  log_remove_context
}

_agent_write_job() {
  log_detail "creating job"

  mkdir -p $agent_workspace/persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_name/$agent_job_relative_path

  file_require $agent_persona_job/prompt.md

  cp $agent_persona_job/prompt.md $agent_workspace/persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_name/$agent_job_relative_path

  (
    printf 'agent_job_git_repository=%s\n' "$agent_job_git_repository"
    printf 'agent_extension_type=%s\n' "$agent_extension_type"

    [ -n "$all_file_extensions" ] && printf 'all_file_extensions=1\n'
  ) >$agent_workspace/persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_name/$agent_job_relative_path/job

  [ -n "$agent_job_relative_path" ] && {
    log_warn "batch"

    (
      printf "_agent_job_batcher() {\n"
      printf "  printf '%s\\\n'\n" $agent_job_relative_path
      printf '}\n'
    ) >>$agent_workspace/persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_name/$agent_job_relative_path/job
  }
}

_agent_load_job_cfg() {
  _include_optional $git_worktree_path/.secret/agent/$agent_persona/$agent_job_name_key \
    $git_worktree_path/$agent_job_relative_path/.secret/agent/$agent_persona/$agent_job_name_key
}

_agent_log_persona_job_no_run() {
  log_warn "$1"
  unset agent_persona_job_disabled
}
