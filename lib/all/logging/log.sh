log_colorize_text() {
  printf '\033[%s%s\033[0m' "$1" "$2"
}

log_sanitize_input() {
  sed -e 's/\x1b\[[0-9;]*[mGKH]//g' -e 's/[^[:print:][:space:]]//g' -e 's/  */ /g' -e 's/^ //' -e 's/ $//'
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

log_print_log() {
  local _level=$1 _level_str=$2 _color=$3 _tone=$4 _message="$5"


  [ $_level -lt $conf_log_level ] && return 0

  [ -n "$logging_context" ] &&
    _message="${logging_context} - ${_message}"

  [ -n "$_tone" ] && [ $beep_enabled -eq 1 ] && _beep_beep "$_tone"

  local log_event_date_time="$(date '+%Y/%m/%d %H:%M:%S')"

  log_to_file "$_level_str" "$log_event_date_time" "$_message"
  log_to_console "$_color" "$log_event_date_time" "$_message"
  log_user_log "$_level_str" "$log_event_date_time" "$_message"

  [ -n "$log_syslog" ] && _syslog_syslog "$_message"

  return 0
}



log_app() {
  log_debug "$APPLICATION_NAME:$APPLICATION_CMD - $1 ($$)"
}

log_user_log() { :; }
