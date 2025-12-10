_variable_is_set() {
	env | grep -cqm1 "^$1=.*$"
}

_environment_filter() {
	$_CONF_GNU_GREP -P "(^_CONF_|^_OPTN_|^_INSTALL_|^${_TARGET_APPLICATION_NAME}_)"
}

_environment_dump() {
	[ -z "$_APPLICATION_PIPE_DIR" ] && return

	[ -z "$_ENVIRONMENT_FILE" ] && _ENVIRONMENT_FILE=$_APPLICATION_PIPE_DIR/environment

	mkdir -p $(dirname $_ENVIRONMENT_FILE)
	env | _environment_filter | sort -u | grep -v '^$' | sed -e 's/=/="/' -e 's/$/"/' >>$_ENVIRONMENT_FILE
}

_environment_load() {
	[ -z "$_ENVIRONMENT_FILE" ] && return 1

	[ ! -e "$_ENVIRONMENT_FILE" ] && {
		_WARN "$_ENVIRONMENT_FILE does not exist!"
		return 2
	}

	. $_ENVIRONMENT_FILE 2>/dev/null
}
