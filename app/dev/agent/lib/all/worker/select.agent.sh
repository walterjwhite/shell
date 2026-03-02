_worker_select_random_available_agent() {
  local _agent_provider_dir="$APP_LIBRARY_PATH/provider"

  _selected_agent=$(find "$_agent_provider_dir" -type f | while read agent_file; do
    _agent_name=$(basename "$agent_file" .sh)

    if ! ps aux | grep -v grep | grep -q "$_agent_name"; then
      printf '%s\n' "$_agent_name"
    fi
  done | shuf -n 1)

  if [ -z "$_selected_agent" ]; then
    log_warn "no available agents found, selecting from all agents"
    _selected_agent=$(find "$_agent_provider_dir" -type f -exec basename {} .sh \; | shuf -n 1)
  fi

  log_info "selected agent: $_selected_agent"
  printf '%s\n' "$_selected_agent"
}
