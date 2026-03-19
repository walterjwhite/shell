log_to_file() {
  [ -z "$log_logfile" ] && return 0

  printf '%s %s %s\n' "$1" "$2" "$3" >>$log_logfile
}

log_open_logfile() {
  less +G $log_logfile
}

log_move_logfile() {
  [ -z "$1" ] && return
  [ -z "$log_logfile" ] && {
    log_set_logfile "$1"
    return
  }

  local original_logfile="$log_logfile"
  local original_fifo_pid="$log_fifo_pid"

  log_reset_logging

  log_set_logfile "$1"

  if [ -f "$original_logfile" ] && [ "$original_logfile" != "$log_logfile" ]; then
    cat "$original_logfile" >>"$log_logfile"
    rm -f "$original_logfile"
  fi
}

log_set_logfile() {
  [ -z "$1" ] && return

  log_logfile="$(_file_readlink $(dirname $1))/$(basename $1)"
  mkdir -p $(dirname $log_logfile)

  log_to_console "${conf_log_c_wrn}" "        writing logs to ${log_logfile}${log_msg}"
}
