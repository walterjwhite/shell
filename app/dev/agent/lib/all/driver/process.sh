_driver_is_job_running() {
  pgrep -f "agent-worker $agent_job" >/dev/null 2>&1
}
