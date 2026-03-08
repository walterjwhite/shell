_worker_select_random_available_agent() {
  local _agent_provider_dir="$APP_LIBRARY_PATH/provider"

  _selected_agent=$(find "$_agent_provider_dir" -type f | while read agent_file; do
    _agent_name=$(basename "$agent_file" .sh)


    [ -e $APP_DATA_PATH/$_agent_name ] && {
      local agent_wait_until=$(head -1 $APP_DATA_PATH/$_agent_name)
      local current_date_time=$(date +%s)

      [ $current_date_time -lt $agent_wait_until ] && {
        log_warn "agent is rate-limited"
        continue
      }

      log_warn "clearing agent wait: $_agent_name"
      rm -f $APP_DATA_PATH/$_agent_name
    }

    printf '%s\n' "$_agent_name"
  done | shuf -n 1)

  validation_require "$_selected_agent" _selected_agent

  log_info "selected agent: $_selected_agent"
  printf '%s\n' "$_selected_agent"
}
