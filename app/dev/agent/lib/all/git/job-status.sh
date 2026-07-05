_agent_git_update_job() {
  log_detail 'updating job status'

  mkdir -p "$2"
  agent_new_job_path=$(printf '%s' "$agent_job" | sed -e "s/$1/$2/")
  mkdir -p "$(dirname "$agent_new_job_path")"
  git mv "$agent_job" "$agent_new_job_path"

  git commit -m "$agent_job_name - $2"
  git push

  agent_job=$agent_new_job_path
}
