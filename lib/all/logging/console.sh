log_to_console() {
  local _color=$1 _event_date_time=$2 _message=$3

  if [ -n "$interactive" ]; then
    if [ "$conf_log_date_time_to_console" -eq 1 ]; then
      printf '\033[%sm%s - %s\033[0m\n' "$_color" "$_event_date_time" "$_message" >&2
    else
      printf '\033[%sm%s\033[0m\n' "$_color" "$_message" >&$console_log_fd
    fi
    return
  fi

  if [ "$conf_log_date_time_to_console" -eq 1 ]; then
    printf '%s - %s\n' "$_event_date_time" "$_message" >&$console_log_fd
  else
    printf '%s\n' "$_message" >&$console_log_fd
  fi
}

_log_print_to_console() {
  printf "%s" "$1" >&$console_log_fd
}

_log_print_newline_to_console() {
  printf '\n' >&$console_log_fd
}
