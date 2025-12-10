_alert() {
	_print_log 5 ALRT "$_CONF_LOG_C_ALRT" "$_CONF_LOG_BEEP_ALRT" "$1"

	local recipients="$_OPTN_LOG_ALERT_RECIPIENTS"
	local subject="Alert: $0 - $1"

	if [ -z "$recipients" ]; then
		_WARN "recipients is empty, aborting"
		return 1
	fi

	_mail "$recipients" "$subject" "$2"
}

_long_running_cmd() {
	[ -n "$_OPTN_DISABLE_LONG_RUNNING_CMD_NOTIFICATION" ] && return

	_APPLICATION_END_TIME=$(date +%s)
	_APPLICATION_RUNTIME=$(($_APPLICATION_END_TIME - $_APPLICATION_START_TIME))
	[ $_APPLICATION_RUNTIME -lt $_CONF_LOG_LONG_RUNNING_CMD ] && return

	local subject="[$_APPLICATION_NAME] - $_EXIT_MESSAGE - ($_EXIT_STATUS)"
	local message=""
	if [ -n "$_LOGFILE" ]; then
		message=$(tail -$_CONF_LOG_LONG_RUNNING_CMD_LINES $_LOGFILE | _sed_remove_nonprintable_characters)
	fi

	_alert "$subject" "$message"
}
