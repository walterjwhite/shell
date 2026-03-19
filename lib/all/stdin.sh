_stdin_interactive_alert_if() {
  _stdin_is_interactive_alert_enabled && _interactive_alert "$@"
}

_stdin_is_interactive_alert_enabled() {
  grep -cq '^optn_log_interactive_alert=1$' $APP_CONFIG_PATH 2>/dev/null
}

_stdin_read_ifs() {
  stty -echo
  _stdin_read_if "$@"
  stty echo
}

_stdin_continue_if() {
  unset _proceed
  _stdin_read_if "$1" _proceed "$2"
  if [ -z "$_proceed" ]; then
    _default=$(printf '%s' $2 | awk -F'/' {'print$1'})
    _proceed=$_default
  fi

  printf '%s' "$_proceed" | tr '[:lower:]' '[:upper:]' | $GNU_GREP -Pcqm1 '^Y$'
}

_stdin_read_if() {
  if [ $(set | grep -c "^$2=.*") -eq 1 ]; then
    log_debug "$2 is already set"
    return 1
  fi

  [ -z "$interactive" ] && exit_with_error "running in non-interactive mode and user input was requested: $@" 10

  log_print_log 9 STDI "$conf_log_c_stdin" "$conf_log_beep_stdin" "$1 $3"
  _stdin_interactive_alert_if $1 $3

  read -r $2
}
