_worker_wait_for_agent_rate_limit() {
  log_warn "hit rate limit"

  local agent_backoff_epoch=$(_agent_rate_limit_wait)

  mkdir -p $APP_DATA_PATH
  printf '%s\n' $agent_backoff_epoch >$APP_DATA_PATH/$agent_worker.backoff

  local now=$(_time_current_time_unix_epoch)
  local delta=$(($agent_backoff_epoch - $now))

  if [ $delta -gt $conf_agent_rate_limit_wait_time ]; then
    log_warn "need to wait $delta before retrying > $conf_agent_rate_limit_wait_time"

    job_tries_remaining=0
  else
    log_warn "waiting $delta for rate limit to clear"
    sleep $delta

    rm -f $APP_DATA_PATH/$agent_worker.backoff
  fi
}
