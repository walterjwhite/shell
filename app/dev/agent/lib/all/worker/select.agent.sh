_worker_select_random_available_agent() {
  local _selected_agent=$(find "$APP_PATH/provider" -type f | while read agent_file; do
    local _agent_worker=$(basename "$agent_file" .sh)

    _worker_is_disabled $_agent_worker && continue
    _worker_select_is_rate_limited $_agent_worker && continue

    printf '%s\n' "$_agent_worker"
  done | shuf -n 1)

  validation_require "$_selected_agent" _selected_agent

  log_info "selected agent: $_selected_agent"
  printf '%s\n' "$_selected_agent"
}

_worker_is_disabled() {
  set | grep -cqm1 "^agent_${1}_disabled=" && {
    log_warn "$1 is disabled"
    return 0
  }

  return 1
}

_worker_select_is_rate_limited() {
  [ -e $APP_DATA_PATH/$1 ] && {
    local agent_wait_until=$(head -1 $APP_DATA_PATH/$1.backoff)
    local current_date_time=$(date +%s)

    [ $current_date_time -lt $agent_wait_until ] && {
      log_warn "agent is rate-limited"
      return 0
    }

    log_warn "clearing agent wait: $1"
    rm -f $APP_DATA_PATH/$1.backoff
  }

  return 1
}

_worker_is_running() {
  ps aux | grep -v grep | grep -cqm1 "$1"
}
