log_to_console() {
  local _color=$1 _event_date_time=$2 _message=$3

  [ -n "$interactive" ] && {
    if [ "$conf_log_date_time_to_console" -eq 1 ]; then
      printf >&2 '\033[%s%s - %s \033[0m\n' "$_color" "$_event_date_time" "$_message"
    else
      printf >&2 '\033[%s%s \033[0m\n' "$_color" "$_message"
    fi

    return
  }

  if [ "$conf_log_date_time_to_console" -eq 1 ]; then
    printf >&2 '%s - %s\n' "$_event_date_time" "$_message"
  else
    printf >&2 '%s\n' "$_message"
  fi
}

log_print_to_console() {
  printf >&2 "%s" "$1"
}

log_print_newline_to_console() {
  printf >&2 '\n'
}
