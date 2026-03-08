lib git/include.sh
lib ./git.sh

agent_extension_batch() {
  log_add_context "persona-$agent_persona"

  _extension_load_type

  agent_invocation_wd=$PWD
  _agent_git_init_workspace
  for agent_persona_job in $(find __LIBRARY_PATH__/__APPLICATION_NAME__/personas/$agent_persona -maxdepth 1 -mindepth 1 -type d | sort -V); do
    agent_job_name=$(basename $agent_persona_job)

    _agent_get_job_name_key

    log_add_context $agent_job_name_key

    _agent_extension_create_batches_for_persona_job
    _agent_extension_run_jobs

    log_remove_context
  done

  log_remove_context
}

_agent_extension_create_batches_for_persona_job() {
  cd $agent_invocation_wd
  for agent_job_relative_path in $(extension_find_dirs_containing | sort -r); do
    [ -n "$agent_batch_skip_root" ] && [ "$batch_dir" = "." ] && {
      log_warn "skipping root dir"
      continue
    }

    _agent_extension_create_job
  done

  cd $agent_workspace

  git add persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_name
  git commit -m "created jobs for $agent_persona - $agent_project"
  git push

  unset agent_job_relative_path
}

_agent_extension_run_jobs() {
  log_add_context run_jobs
  log_detail "$batch_dir | $PWD"

  _agent_get_job_name_key

  for agent_job in $(find persona/$agent_persona/$agent_project/$extension_run_type/$agent_job_name -type d ! -name log | sort -r); do
    agent-worker $agent_job &
    agent_worker_pid=$!
    exit_defer kill -9 $agent_worker_pid

    _agent_extension_tail_logs &
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

_agent_extension_tail_logs() {
  sleep 1

  local child_log_dir="$agent_job/log"

  local child_log_file=$(ls -t "$child_log_dir" 2>/dev/null | head -1)
  [ -n "$child_log_file" ] && {
    child_log_file="$child_log_dir/$child_log_file"

    log_detail "launching log viewer: $log_logfile | $child_log_file"

    tail -f $child_log_file
    git add $child_log_file
    git commit $child_log_file -m "$agent_job logs"
    git push
    return
  }

  log_warn "unable to initialize log viewer: $log_logfile | $child_log_file"
}
