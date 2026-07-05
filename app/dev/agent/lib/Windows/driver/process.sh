_driver_is_job_running() {
  ps aux | grep -v grep | grep -cqm1 "agent-worker $agent_job"
}
