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

  _recipients="$optn_log_alert_recipients"
  _subject="Alert: $0 - $1"

  if [ -z "$_recipients" ]; then
    log_debug "recipients is empty, aborting"
    return 1
  fi

  _mail "$_recipients" "$_subject" "$2"
}

_alert_long_running_cmd() {
  [ -n "$optn_disable_long_running_cmd_notification" ] && return

  local _application_end_time
  local _application_runtime
  local _subject
  local _message
  _application_end_time=$(date +%s)
  _application_runtime=$(($_application_end_time - $APPLICATION_START_TIME))
  [ $_application_runtime -lt $conf_log_long_running_cmd ] && return

  _subject="[$APPLICATION_NAME] - $exit_message - ($exit_status)"
  _message=""
  if [ -n "$log_logfile" ]; then
    _message=$(tail -$conf_log_long_running_cmd_lines $log_logfile)
  fi

  _alert_alert "$_subject" "$_message"
}
