worker_sandbox_commit_local() {
  cd $worker_agent_job_path

  git add log
  git commit log -m 'add log' || log_detail "no new log content to commit"
  git push

  cd $agent_job_work_path
  git add .
  git commit -m "$agent_worker - $agent_job_name_key" || {
    log_warn "nothing to commit in $agent_job_work_path — agent produced no changes"
    return 1
  }
  git push -u
}
