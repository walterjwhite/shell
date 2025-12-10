_interactive_alert_if() {
	_is_interactive_alert_enabled && _interactive_alert "$@"
}

_is_interactive_alert_enabled() {
	grep -cq '^_OPTN_LOG_INTERACTIVE_ALERT=1$' $_CONF_APPLICATION_CONFIG_PATH 2>/dev/null
}

_read_ifs() {
	stty -echo
	_read_if "$@"
	stty echo
}

_continue_if() {

	_read_if "$1" _PROCEED "$2"

	local proceed="$_PROCEED"
	unset _PROCEED

	if [ -z "$proceed" ]; then
		_DEFAULT=$(printf '%s' $2 | awk -F'/' {'print$1'})
		proceed=$_DEFAULT
	fi

	local proceed=$(printf '%s' "$proceed" | tr '[:lower:]' '[:upper:]')
	if [ $proceed = "N" ]; then
		return 1
	fi

	return 0
}

_read_if() {
	if [ $(env | grep -c "^$2=.*") -eq 1 ]; then
		_DEBUG "$2 is already set"
		return 1
	fi

	[ -z "$INTERACTIVE" ] && _ERROR "Running in non-interactive mode and user input was requested: $@" 10

	_print_log 9 STDI "$_CONF_LOG_C_STDIN" "$_CONF_LOG_BEEP_STDIN" "$1 $3"
	_interactive_alert_if $1 $3

	read -r $2
}
