log_to_file() {
  [ -z "$log_logfile" ] && return 0

  printf '%s %s %s\n' "$1" "$2" "$3" >>$log_logfile
}

_log_open_logfile() {
  less +G $log_logfile
}

_log_move_logfile() {
  [ -z "$1" ] && return
  [ -z "$log_logfile" ] && {
    _log_set_logfile "$1"
    return
  }

  local original_logfile="$log_logfile"
  local original_fifo_pid="$log_fifo_pid"

  _log_set_logfile "$1"

  if [ -f "$original_logfile" ] && [ "$original_logfile" != "$log_logfile" ]; then
    cat "$original_logfile" >>"$log_logfile"
    rm -f "$original_logfile"
  fi
}

_log_set_logfile() {
  [ -z "$1" ] && return

  log_logfile="$(_file_readlink $(dirname $1))/$(basename $1)"
  mkdir -p $(dirname $log_logfile)

  log_to_console "${conf_log_c_wrn}" "$(date '+%Y/%m/%d %H:%M:%S')" "writing logs to ${log_logfile}${log_msg}"

  if [ -z "${_log_saved_fds}" ]; then
    exec 3>&1 4>&2
    _log_saved_fds=1
    console_log_fd=4
  fi

  exec >>"$log_logfile" 2>&1
}

_log_restore_fds() {
  [ -z "${_log_saved_fds}" ] && return

  exec 1>&3 2>&4 # restore stdout/stderr
  exec 3>&- 4>&- # close saved FDs
  console_log_fd=2
  unset _log_saved_fds
}
