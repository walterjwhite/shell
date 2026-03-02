log_warn() {
  log_print_log 3 WRN "${conf_log_c_wrn}" "${conf_log_beep_wrn}" "$1"
}

log_info() {
  log_print_log 2 INF "${conf_log_c_info}" "${conf_log_beep_info}" "$1"
}

log_detail() {
  log_print_log 2 DTL "${conf_log_c_detail}" "${conf_log_beep_detail}" "$1"
}

log_debug() {
  log_print_log 1 DBG "${conf_log_c_debug}" "${conf_log_beep_debug}" "($$) $1"
}

log_add_context() {
  [ -z "$1" ] && return 1

  case "$1" in
  *:*)
    exit_with_error "context string contains colon, which is not allowed"
    ;;
  esac

  if [ -z "$logging_context" ]; then
    logging_context="$1"
  else
    logging_context="${logging_context}:$1"
  fi
}

log_remove_context() {
  [ -z "$logging_context" ] && return 1

  case $logging_context in
  *:*)
    logging_context=$(printf '%s' "$logging_context" | sed -e 's/\:[a-zA-Z0-9/@\. _-]*$//')
    ;;
  *)
    unset logging_context
    ;;
  esac
}

log_to_console() {
  [ -z "$conf_log_console" ] && return 0

  local _color=$1 _message=$2
  printf >&${conf_log_console} '\033[%s%s \033[0m\n' "$_color" "$_message"
}

log_print_to_console() {
  printf >&${conf_log_console} "%s" "$1"
}

log_print_newline_to_console() {
  printf >&${conf_log_console} '\n'
}

log_colorize_text() {
  printf '\033[%s%s\033[0m' "$1" "$2"
}

log_sanitize_input() {
  sed -e 's/\x1b\[[0-9;]*[mGKH]//g' -e 's/[^[:print:][:space:]]//g' -e 's/  */ /g' -e 's/^ //' -e 's/ $//'
}

log_to_file() {
  [ -z "$log_logfile" ] && return 0

  printf '%s %s %s\n' "$(date '+%Y/%m/%d %H:%M:%S')" "$1" "$2" >>$log_logfile
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

log_init() {

  [ -n "$log_logfile" ] && log_set_logfile "$log_logfile"

  if [ -n "$add_log_context" ]; then
    log_add_context "$add_log_context"
    unset add_log_context
  fi

  log_enable_debug_mode
}

log_enable_debug_mode() {
  [ "$conf_log_level" -gt 0 ] && {
    set +x
    return
  }

  [ -z "$log_logfile" ] && {
    log_msg=" - DEBUG"
    log_set_logfile "$(_mktemp_mktemp debug)" || return 1
  }

  set -x
}

log_set_logfile() {
  [ -z "$1" ] && return

  if ! { >&3; } 2>/dev/null; then
    exec 3>&1 4>&2
  fi

  [ -n "$log_fifo_pid" ] && log_reset_logging

  log_logfile="$(_file_readlink $(dirname $1))/$(basename $1)"

  if [ -z "$log_no_indent" ]; then
    log_redirect_output_with_indent
  else
    log_redirect_output
  fi

  conf_log_console=4

  log_to_console "${conf_log_c_wrn}" "        writing logs to ${log_logfile}${log_msg}"
}

log_redirect_output_with_indent() {
  log_fifo="$log_logfile.fifo"

  mkfifo "$log_fifo" || {
    log_warn "error setting up fifo, falling back to std redirection"
    
    unset log_fifo

    log_redirect_output
    return
  }

  sed -u 's/^/    /' <"$log_fifo" >>"$log_logfile" &
  log_fifo_pid=$!
  exit_defer log_reset_logging

  exec >"$log_fifo" 2>&1
}

log_reset_logging() {
  unset logging_context

  exec 1>&3 2>&4

  log_cleanup_logging
}

log_cleanup_logging() {
  [ -n "$log_fifo_pid" ] && {
    timeout -k 5 -s SIGTERM 1 wait $log_fifo_pid 2>/dev/null
    unset log_fifo_pid
  }

  [ -n "$log_fifo" ] && {
    rm -f $log_fifo 2>/dev/null
    unset log_fifo
  }
}

log_redirect_output() {
  exec >>"$log_logfile" 2>&1
}

log_print_log() {
  local _level=$1 _level_str=$2 _color=$3 _tone=$4 _message="$5"


  [ $_level -lt $conf_log_level ] && return 0

  [ -n "$logging_context" ] &&
    _message="${logging_context} - ${_message}"

  log_handle_background_notification "$_level_str" "$_message"
  [ -n "$_tone" ] && _beep_beep "$_tone"

  log_to_file "$_level_str" "$_message"
  log_to_console "$_color" "$_message"
  log_user_log "$_level_str" "$_message"

  [ -n "$log_syslog" ] && _syslog_syslog "$_message"

  return 0
}



log_handle_background_notification() {
  local _level_str=$1 _message=$2

  [ -z "$backgrounded" ] && return

  [ -z "$optn_install_background_notification_method" ] && return

  $optn_install_background_notification_method "$_level_str" "$_message" &
}

log_app() {
  log_debug "$APPLICATION_NAME:$APPLICATION_CMD - $1 ($$)"
}

log_user_log() { :; }
