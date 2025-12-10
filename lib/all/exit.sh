_ERROR() {
	[ -n "$_EXIT_STATUS" ] && return

	if [ $# -ge 2 ]; then
		_EXIT_STATUS=$2
	else
		_EXIT_STATUS=1
	fi

	_EXIT_LOG_LEVEL=4
	_EXIT_STATUS_CODE="ERR"
	_EXIT_COLOR_CODE="$_CONF_LOG_C_ERR"

	_EXIT_MESSAGE="$1 ($_EXIT_STATUS)"
	_EXIT_BEEP="$_CONF_LOG_BEEP_ERR"

	_defer _environment_dump
	_defer _log_app_exit

	_run_defers

	exit $_EXIT_STATUS
}

_success() {
	[ -n "$_EXIT_STATUS" ] && return

	_EXIT_STATUS=0

	_EXIT_LOG_LEVEL=1
	_EXIT_STATUS_CODE="SCS"
	_EXIT_COLOR_CODE="$_CONF_LOG_C_SCS"

	_EXIT_MESSAGE="$1"
	[ -z "$_EXIT_MESSAGE" ] && _EXIT_MESSAGE="success"

	_EXIT_BEEP="$_CONF_LOG_BEEP_SCS"

	_defer _long_running_cmd
	_defer _log_app_exit

	_run_defers

	exit $_EXIT_STATUS
}

_on_hup() {
	:
}

_on_int() {
	_ERROR "interrupted"
}

_on_quit() {
	_ERROR "quit"
}

_on_illegal() {
	_ERROR "illegal instruction"
}

_on_abort() {
	_ERROR "abort"
}

_on_alarm() {
	_ERROR "alarm"
}

_on_term() {
	_ERROR "term"
}

_defer() {
	if [ -n "$_DEFERS" ]; then
		local defer
		for defer in $_DEFERS; do
			[ "$defer" = "$1" ] && {
				_DEBUG "not deferring: $1 as it was already deferred"
				return
			}
		done
	fi

	_DEBUG "deferring: $1"
	_DEFERS="$1 $_DEFERS"
}

_run_defers() {
	[ -z "$_DEFERS" ] && return 1

	local defer
	for defer in $_DEFERS; do
		_call $defer
	done

	unset _DEFERS
}

_log_app_exit() {
	[ "$_EXIT_MESSAGE" ] && {
		local current_time=$(date +%s)
		local timeout=$(($_APPLICATION_START_TIME + $_CONF_LOG_BEEP_TIMEOUT))
		[ $current_time -le $timeout ] && unset _EXIT_BEEP

		_print_log $_EXIT_LOG_LEVEL "$_EXIT_STATUS_CODE" "$_EXIT_COLOR_CODE" "$_EXIT_BEEP" "$_EXIT_MESSAGE"
	}

	_log_app exit

	[ -n "$_LOGFILE" ] && [ -n "$_OPTN_LOG_EXIT_CMD" ] && {
		$_OPTN_LOG_EXIT_CMD -file $_LOGFILE
	}
}
