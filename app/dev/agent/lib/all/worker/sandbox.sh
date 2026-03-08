lib git/archive.sh

_worker_sandbox_init() {
  agent_job_work_path=$(_mktemp_options=d _mktemp_mktemp)
  exit_defer rm -rf $agent_job_work_path

  [ -z "$agent_job_git_branch" ] && agent_job_git_branch=main

  _agent_get_job_name_key

  _git_archive_filter $agent_job_git_repository "$agent_job_git_branch" "$worker_agent_job_work_item" "$file_extension_filter" $agent_job_work_path

  exec_call _agent_batch_extension_filter

  cd $agent_job_work_path
  git init
  git add .
  git commit -am 'init work'

  agent_work_initial_commit=$(git rev-parse --short=8 HEAD --)
}

_worker_sandbox_run() {
  _agent_cmd
  _worker_job_logfile=$(_mktemp_mktemp)
  exit_defer rm -f $_worker_job_logfile

  cp $worker_agent_prompt $agent_job_work_path/PROMPT.md

  sandbox_marker="/tmp/sandbox-session-$$"
  printf '%s' "$$" >"$sandbox_marker"

  exit_defer _worker_cleanup_sandbox

  INPUT_DIR=$agent_job_work_path podman-compose -f __LIBRARY_PATH__/__APPLICATION_NAME__/container/dev/docker-compose.yml run --rm sandbox bash -c "$_AGENT_CMD < /input/PROMPT.md" 2>&1 | tee $_worker_job_logfile &
  local sandbox_pid=$!

  printf '%s' "$sandbox_pid" >>"$sandbox_marker"

  wait $sandbox_pid
}

_worker_sandbox_patch() {
  log_detail "creating patch"
  cd $agent_job_work_path

  rm -f PROMPT.md

  find . -type f -iname '*.md' -print -quit | grep -cqm1 '.' && {
    log_detail "organizing docs"

    mkdir -p doc.secret
    mv *.md doc.secret

    git add doc.secret
  }

  find . ! -path '*/.git/*' -type f

  git add $(find . -type f ! -path '*/*.git/*' -name '*.md')

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
  git checkout -b $agent_get_job_name_key
  git apply $agent_job_work_path/patch
  git add .
  git commit -am "agent - $worker_agent_job_work_item"
  git push

  cd ..
  rm -rf $agent_job_git_path
}

_worker_cleanup_sandbox() {
  log_detail "cleaning up sandbox processes..."

  pkill -P $$ podman-compose 2>/dev/null || true

  podman-compose -f __LIBRARY_PATH__/__APPLICATION_NAME__/container/dev/docker-compose.yml down 2>/dev/null || true

  podman ps -a --filter "label=com.docker.compose.project=dev" --format "{{.ID}}" | xargs -r podman rm -f 2>/dev/null || true

  rm -f "$sandbox_marker"
}
