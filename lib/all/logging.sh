_init_logging() {
	[ -n "$_LOGFILE" ] && _set_logfile "$_LOGFILE"

	case $_CONF_LOG_LEVEL in
	0)
		local logfile=$(_mktemp debug)

		_WARN "Writing debug contents to: $logfile"
		_set_logfile "$logfile"
		set -x
		;;
	esac
}

_set_logfile() {
	[ -z "$1" ] && return 1

	_LOGFILE=$1

	mkdir -p $(dirname $1)
	_reset_indent


	[ -n "$INTERACTIVE" ] && [ $_CONF_LOG_CONSOLE -eq 2 ] && {
		exec 3>&1 4>&2
		_CONF_LOG_CONSOLE=4
	}

	exec >>$_LOGFILE 2>&1

	_log_to_console "$_CONF_LOG_C_WRN" "writing logs to $_LOGFILE"

	[ -n "$_PRESERVE_LOG" ] && return

	truncate -s 0 $1 >/dev/null 2>&1
}

_reset_logging() {
	[ !-t 3 ] && return

	exec 1>&3
	exec 2>&4

	exec 3>&-
	exec 4>&-
}

_WARN() {
	_print_log 3 WRN "$_CONF_LOG_C_WRN" "$_CONF_LOG_BEEP_WRN" "$1"
}

_INFO() {
	_print_log 2 INF "$_CONF_LOG_C_INFO" "$_CONF_LOG_BEEP_INFO" "$1"
}

_DETAIL() {
	_print_log 2 DTL "$_CONF_LOG_C_DETAIL" "$_CONF_LOG_BEEP_DETAIL" "$1"
}

_DEBUG() {
	_print_log 1 DBG "$_CONF_LOG_C_DEBUG" "$_CONF_LOG_BEEP_DEBUG" "($$) $1"
}


_log() {
	:
}

_colorize_text() {
	printf '\033[%s%s\033[0m' "$1" "$2"
}

_sed_remove_nonprintable_characters() {
	sed -e 's/[^[:print:]]//g'
}

_print_log() {
	if [ -z "$5" ]; then
		if test ! -t 0; then
			local log_line
			cat - | _sed_remove_nonprintable_characters |
				while read log_line; do
					_print_log $1 $2 $3 $4 "$log_line"
				done
			return
		fi

		return
	fi
	local message="$5"

	[ $1 -lt $_CONF_LOG_LEVEL ] && return

	[ -n "$_LOGGING_CONTEXT" ] && message="$_LOGGING_CONTEXT - $message"

	if [ $_BACKGROUNDED ] && [ $_OPTN_INSTALL_BACKGROUND_NOTIFICATION_METHOD ]; then
		$_OPTN_INSTALL_BACKGROUND_NOTIFICATION_METHOD "$2" "$_message" &
	fi

	[ -n "$4" ] && _beep "$4"

	_log_to_file "$2" "${_LOG_INDENT}$message"
	_log_to_console "$3" "${_LOG_INDENT}$message"

	[ -z "$INTERACTIVE" ] && _syslog "$message"
	return 0
}

_add_logging_context() {
	[ -z "$1" ] && return 1

	if [ -z "$_LOGGING_CONTEXT" ]; then
		_LOGGING_CONTEXT="$1"
		return
	fi

	_LOGGING_CONTEXT="$_LOGGING_CONTEXT.$1"
}

_remove_logging_context() {
	[ -z "$_LOGGING_CONTEXT" ] && return 1

	case $_LOGGING_CONTEXT in
	*.*)
		_LOGGING_CONTEXT=$(printf '%s' "$_LOGGING_CONTEXT" | sed 's/\.[a-z0-9 _-]*$//')
		;;
	*)
		unset _LOGGING_CONTEXT
		;;
	esac
}

_increase_indent() {
	_LOG_INDENT="$_LOG_INDENT${_CONF_LOG_INDENT}"
}

_decrease_indent() {
	_LOG_INDENT=$(printf '%s' "$_LOG_INDENT" | sed -e "s/${_CONF_LOG_INDENT}$//")
	[ ${#_LOG_INDENT} -eq 0 ] && _reset_indent
}

_reset_indent() {
	unset _LOG_INDENT
}

_log_to_file() {
	[ -z "$_LOGFILE" ] && return

	printf '%s\n' "$2" >>$_LOGFILE
}

_log_to_console() {
	printf >&$_CONF_LOG_CONSOLE '\033[%s%s \033[0m\n' "$1" "$2"
}

_log_app() {
	_DEBUG "$_APPLICATION_NAME:$_APPLICATION_CMD - $1 ($$)"
}
