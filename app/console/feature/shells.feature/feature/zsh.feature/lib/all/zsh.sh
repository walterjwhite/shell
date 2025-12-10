lib net/hostname.sh

_after() {
	local -i cmd_status=$?
	[ -z "$_CURRENT_TIME" ] && return

	local now=$(_current_time_epoch)
	local cmd_runtime=$(($now - $_CURRENT_TIME))

	if [ $cmd_runtime -gt 0 ]; then
		_console_log 'After ' " - ${cmd_runtime}s"
	else
		_console_log 'After '
	fi

	if [ $now -gt $_TIMEOUT ]; then
		local cmd_status_description=completed
		[ $cmd_status -gt 0 ] && cmd_status_description=failed

		cmd_status=$cmd_status _interactive_alert_if "$_COMMAND $cmd_status_description"
	fi

	unset _CURRENT_TIME
}

_before() {
	_CURRENT_TIME=$(_current_time_epoch)
	_COMMAND=$1

	_TIMEOUT=$(($_CURRENT_TIME + $_CONF_CONSOLE_SCRIPT_TIMEOUT))

	_console_is_refresh_context $1 && _console_context

	_console_log Before
}

_set_histfile() {
	HISTFILE_PATH=$(_hostname)/activity
	HISTFILE_REL_PATH=$_CONSOLE_CONTEXT_ID/$HISTFILE_PATH
	HISTFILE=$_CONSOLE_CONTEXT_DIRECTORY/$HISTFILE_PATH/$(date +%Y/%m/%d)

	mkdir -p $(dirname $HISTFILE)
}

_current_time_epoch() {
	date +%s
}

_save_console_history() {
	[ ! -e $HISTFILE ] && return 1

	[ $(wc -l <$HISTFILE) -eq 0 ] && return 2

	local opwd=$PWD
	cd $_PROJECT_PATH
	_console_data_has_changes && _git_save "$(date +'%Y/%m/%d %H:%M:%S')" $HISTFILE_REL_PATH

	cd $opwd
}

_console_data_has_changes() {
	[ $(git status --porcelain 2>/dev/null | wc -l) -gt 0 ]
}

_console_date() {
	date +"$_CONF_LOG_DATE_FORMAT"
}

_console_log() {
	local message="$1"

	[ "$_CONSOLE_CONTEXT_ID" ] && message="[$_CONSOLE_CONTEXT_ID] $message"
	printf '\e[1;3;%sm### %s - %s ###\e[0m\n' "$_CONF_CONSOLE_AUDIT_COLOR" "$message" "$(_console_date)$2"
}
