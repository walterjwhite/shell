_worker_sandbox_init_container() {
  _git_archive_filter $agent_job_git_repository "$agent_job_git_branch" "$worker_agent_job_work_item" "$file_extension_filter" $agent_job_work_path

  exec_call _agent_batch_extension_filter

  cd $agent_job_work_path || exit_with_error "unable to cd to $agent_job_work_path"

  git init
  git add .
  git commit -am 'init work'

  agent_work_initial_commit=$(git rev-parse --short=8 HEAD --)
}

_worker_sandbox_run_container() {
  log_info "running job in podman container"

  sandbox_marker="/tmp/sandbox-session-$$"
  printf '%s' "$$" >"$sandbox_marker"

  exit_defer _worker_cleanup_sandbox

  printf '### sandbox logs\n' >>$log_logfile

  export INPUT_DIR=$agent_job_work_path

  _agent_cmd
  podman-compose -f __APP_PLATFORM_PATH__/apps/__APPLICATION_NAME__/container/dev/docker-compose.yml run --rm sandbox bash -c "$_AGENT_CMD < /input/prompt.md" 2>&1 | log_sanitize_input >>$log_logfile
}

_worker_sandbox_patch() {
  log_detail "creating patch"
  cd $agent_job_work_path

  rm -f prompt.md

  find . -maxdepth 1 -mindepth 1 -type f -name '*.md' ! -name 'prompt.md' -print -quit | grep -cqm1 '.' && {
    log_detail "organizing docs"

    mkdir -p doc.secret
    mv *.md doc.secret

    git add doc.secret
  }

  [ $conf_log_level -eq 0 ] && find . ! -path '*/.git/*' -type f

  if [ -n "$file_extension_filter" ]; then
    git add $(find . -type f ! -path '*/*.git/*' -name "$file_extension_filter")
  else
    git ls-files -o -m --exclude-standard | while IFS= read -r file; do
      if file --mime "$file" | grep -q 'charset=binary'; then
        log_warn "skipping binary: $file"
      else
        git add "$file"
      fi
    done
  fi

  git commit -am 'final work'

  git diff $agent_work_initial_commit >patch

  [ -s patch ] || {
    log_warn "empty patch"
    rm -f patch

    return 1
  }
}

_worker_apply_patch() {
  agent_job_git_path=$(_mktemp_options=d _mktemp_mktemp)
  exit_defer rm -rf $agent_job_git_path

  git clone $agent_job_git_repository -b $agent_job_git_branch $agent_job_git_path
  cd $agent_job_git_path

  log_detail "patching"
  git checkout -b $agent_job_name_key
  git apply $agent_job_work_path/patch
  git add .

  local worker_message="$worker_agent_job_work_item"
  [ -z "$worker_message" ] && {
    worker_message="$agent_job_name_key"
  }

  git commit -am "agent - $worker_message"
  git push

  cd ..
  rm -rf $agent_job_git_path
}
