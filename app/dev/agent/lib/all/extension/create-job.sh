lib io/file.sh

_agent_extension_create_workspace_jobs_for_persona_job() {
  cd $agent_invocation_wd
  for agent_job_relative_path in $(extension_find_dirs_containing | sort -r); do
    [ -n "$agent_batch_skip_root" ] && [ "$agent_job_relative_path" = "." ] && {
      log_warn "skipping root dir"
      continue
    }

    _agent_extension_create_workspace_job
  done

  cd $agent_workspace

  git add persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_name
  git commit -m "created jobs for $agent_persona - $agent_project"
  git push

  unset agent_job_relative_path
}

_agent_extension_create_workspace_job() {
  _agent_extension_set_source_project_from_git_remote
  _agent_extension_require_source_project

  log_add_context $agent_job_relative_path

  _agent_load_persona_job_cfg

  [ -n "$agent_persona_job_disabled" ] && {
    _agent_log_skipped_persona_job "disabled"
    log_remove_context
    return 1
  }

  _agent_write_workspace_job_files
  log_remove_context
}

_agent_extension_set_source_project_from_git_remote() {
  agent_job_git_repository=$(git remote -v | head -1 | awk {'print$2'})
  agent_project=$(basename $agent_job_git_repository | sed -e 's/\.git$//')
  agent_extension_type=$extension_run_type
}

_agent_extension_require_source_project() {
  validation_require "$agent_job_git_repository" agent_job_git_repository
}

_agent_write_workspace_job_files() {
  log_detail "creating job"

  local agent_job_target_path
  agent_job_target_path=$(_agent_workspace_job_target_path)
  mkdir -p $agent_job_target_path

  file_require $agent_persona_job/prompt.md

  cp $agent_persona_job/prompt.md $agent_job_target_path

  _agent_write_workspace_job_config $agent_job_target_path/job
  _agent_write_workspace_job_batcher $agent_job_target_path/job
}

_agent_workspace_job_target_path() {
  printf '%s\n' "$agent_workspace/persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_name/$agent_job_relative_path"
}

_agent_write_workspace_job_config() {
  (
    printf 'agent_job_git_repository=%s\n' "$agent_job_git_repository"
    printf 'agent_extension_type=%s\n' "$agent_extension_type"

    [ -n "$all_file_extensions" ] && printf 'all_file_extensions=1\n'
  ) >$1
}

_agent_write_workspace_job_batcher() {
  [ -n "$agent_job_relative_path" ] && {
    log_warn "batch"

    (
      printf "_agent_job_batcher() {\n"
      printf "  printf '%s\\\n'\n" $agent_job_relative_path
      printf '}\n'
    ) >>$1
  }
}

_agent_load_persona_job_cfg() {
  _include_optional $git_worktree_path/.secret/agent/$agent_persona/$agent_job_name_key \
    $git_worktree_path/$agent_job_relative_path/.secret/agent/$agent_persona/$agent_job_name_key
}

_agent_log_skipped_persona_job() {
  log_warn "$1"
  unset agent_persona_job_disabled
}
