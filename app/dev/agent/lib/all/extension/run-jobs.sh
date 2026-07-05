_agent_extension_run_workspace_jobs() {
  log_add_context run_jobs
  log_detail "$batch_dir | $PWD"

  _agent_get_job_name_key

  for agent_job in $(find persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_name -type d ! -name log | sort -r); do
    agent-worker $agent_job &
    agent_worker_pid=$!
    exit_defer kill -9 $agent_worker_pid

    _agent_extension_follow_worker_log &
    agent_tail_pid=$!
    exit_defer kill -9 $agent_tail_pid

    wait $agent_worker_pid
    local worker_exit=$?

    [ -n "$agent_tail_pid" ] && kill $agent_tail_pid 2>/dev/null

    [ $worker_exit -ne 0 ] && {
      log_warn "job did not complete successfully: $worker_exit"
    }
  done
  log_remove_context
}

_agent_extension_follow_worker_log() {
  sleep 1

  local child_log_dir="$agent_job/log"

  local _wait=0
  while [ $_wait -lt 10 ]; do
    local child_log_file
    child_log_file=$(ls -t "$child_log_dir" 2>/dev/null | head -1)
    [ -n "$child_log_file" ] && break
    sleep 1
    _wait=$((_wait + 1))
  done

  [ -z "$child_log_file" ] && {
    log_warn "unable to find log file in $child_log_dir after ${_wait}s"
    return 1
  }

  child_log_file="$child_log_dir/$child_log_file"
  log_detail "following worker log: $child_log_file"

  tail -f "$child_log_file"
}

_agent_extension_commit_worker_log() {
  local child_log_dir="$agent_job/log"
  local child_log_file
  child_log_file=$(ls -t "$child_log_dir" 2>/dev/null | head -1)
  [ -z "$child_log_file" ] && return 0

  child_log_file="$child_log_dir/$child_log_file"
  git add "$child_log_file"
  git commit "$child_log_file" -m "$agent_job logs" 2>/dev/null || true
  git push
}
