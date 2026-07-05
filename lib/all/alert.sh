_alert_alert() {
  local _recipients
  local _subject
  local _log_color
  case $exit_status in
  0)
    _log_color=$conf_log_c_scs
    ;;
  *)
    _log_color=$conf_log_c_err
    ;;
  esac

  log_print_log 5 ALRT "$_log_color" "$conf_log_beep_alrt" "$1"

  _recipients="$alert_recipients"
  _subject="alert: $0 - $1"

  if [ -z "$_recipients" ]; then
    log_debug "recipients is empty, aborting"
    return 1
  fi

  _mail_send "$_recipients" "$_subject" "$2"
}

_alert_long_running_cmd() {
  [ -n "$disable_long_running_cmd_notifications" ] && return

  local _application_end_time=$(date +%s)
  local _application_runtime=$(($_application_end_time - $APPLICATION_START_TIME))
  [ $_application_runtime -lt $conf_log_long_running_cmd ] && return

  local _subject="$logging_context - $exit_message - ($exit_status)"
  local _message=""
  if [ -n "$log_logfile" ]; then
    _message=$(tail -$conf_log_long_running_cmd_lines $log_logfile)
  fi

  _alert_alert "$_subject" "$_message"
}
