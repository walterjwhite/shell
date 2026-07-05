_agent_get_job_name_key() {
  agent_job_name_key="${agent_job_name#[0-9][0-9].}"
  agent_job_name_key="${agent_job_name_key%.job}"
}
