worker_sandbox_init_container() {
  _git_archive_filter $agent_job_git_repository "$agent_job_git_branch" "$worker_agent_job_work_item" "$file_extension_filter" $agent_job_work_path

  exec_call _agent_batch_extension_filter

  cd $agent_job_work_path || exit_with_error "unable to cd to $agent_job_work_path"

  git init
  git add .
  git commit -am 'init work'

  agent_work_initial_commit=$(git rev-parse --short=8 HEAD --)
}

worker_sandbox_run_container() {
  log_info "running job in podman container"

  sandbox_marker="/tmp/sandbox-session-$$"
  printf '%s' "$$" >"$sandbox_marker"

  exit_defer _worker_cleanup_sandbox

  printf '### sandbox logs\n' >>$log_logfile

  export INPUT_DIR=$agent_job_work_path

  _agent_cmd

  #
  local _pipe_status_file
  _pipe_status_file=$(_mktemp_mktemp)

  {
    podman-compose -f $APP_PATH/container/dev/docker-compose.yml run --rm sandbox bash -c "$_AGENT_CMD < /input/prompt.md"
    printf '%s' "$?" >"$_pipe_status_file"
  } 2>&1 | log_sanitize_input >>$log_logfile

  local _container_status
  _container_status=$(cat "$_pipe_status_file" 2>/dev/null)
  rm -f "$_pipe_status_file"

  return "${_container_status:-1}"
}

_worker_export_container_work_as_patch() {
  log_detail "creating patch"
  cd $agent_job_work_path

  _worker_remove_container_prompt_file
  _worker_move_container_generated_docs
  _worker_sync_job_log_to_work_tree
  _worker_stage_container_changes
  _worker_commit_container_work
  _worker_write_container_patch_file
}

_worker_remove_container_prompt_file() {
  rm -f prompt.md
}

_worker_move_container_generated_docs() {
  find . -maxdepth 1 -mindepth 1 -type f -name '*.md' ! -name 'prompt.md' -print -quit | grep -cqm1 '.' && {
    log_detail "organizing docs"

    mkdir -p doc.secret
    mv *.md doc.secret

    git add doc.secret
  }
}

_worker_stage_container_changes() {
  [ $conf_log_level -eq 0 ] && find . ! -path '*/.git/*' -type f

  if [ -n "$file_extension_filter" ]; then
    _worker_stage_container_files_by_extension
    return
  fi
  _worker_stage_container_text_files
}

_worker_stage_container_files_by_extension() {
  git add $(find . -type f ! -path '*/*.git/*' -name "$file_extension_filter")
  git add log
}

_worker_stage_container_text_files() {
  git ls-files -o -m --exclude-standard | while IFS= read -r file; do
    if file --mime "$file" | grep -q 'charset=binary'; then
      log_warn "skipping binary: $file"
    else
      git add "$file"
    fi
  done
}

_worker_commit_container_work() {
  git commit -m 'final work'
}

_worker_write_container_patch_file() {
  git diff $agent_work_initial_commit >patch

  [ -s patch ] || {
    log_warn "empty patch"
    rm -f patch

    return 1
  }
}

_worker_apply_container_patch_to_repository() {
  agent_job_git_path=$(_mktemp_options=d _mktemp_mktemp)
  exit_defer rm -rf $agent_job_git_path

  _worker_checkout_container_patch_target
  _worker_commit_container_patch

  cd ..
  rm -rf $agent_job_git_path
}

_worker_checkout_container_patch_target() {
  git clone $agent_job_git_repository -b $agent_job_git_branch $agent_job_git_path
  cd $agent_job_git_path

  log_detail "patching"
  git checkout -b $agent_job_name_key
  git apply $agent_job_work_path/patch
  git add .
}

_worker_commit_container_patch() {
  local worker_message="$worker_agent_job_work_item"
  [ -z "$worker_message" ] && {
    worker_message="$agent_job_name_key"
  }

  git commit -m "agent - $worker_message"
  git push -u
}

worker_sandbox_commit_container() {
  _worker_export_container_work_as_patch
  _worker_apply_container_patch_to_repository
}
