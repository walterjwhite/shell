_processes_is_backgrounded && backgrounded=1

[ -n "$NON_INTERACTIVE" ] && {
  [ -z "$NO_LOG_FILE" ] && {
    [ -z "$log_logfile" ] && log_logfile="$APP_DATA_PATH/log/$(date +%Y%m%d-%H%M%S).log"
  }
}

log_init
