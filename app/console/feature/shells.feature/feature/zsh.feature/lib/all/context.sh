lib git/include.sh

_console_context() {
	_INFO "Refreshing console context"

	if [ ! -e $_CONF_APPLICATION_DATA_PATH/active ]; then
		_WARN "Using default context"

		_CONSOLE_CONTEXT_ID=default
		_CONSOLE_CONTEXT_DESCRIPTION=default
		_console_context_write
	fi

	_console_read_context

	_console_pull_is_running || {
		_console_pull_print_output

		_console_shall_sync && {
			_console_pull &
			_CONSOLE_PULL_PID=$?

			disown >/dev/null 2>&1
		}
	}
}

_console_read_context() {
	_CONSOLE_CONTEXT_EXPIRATION=$(($_CURRENT_TIME + $_CONF_CONSOLE_CONTEXT_TIMEOUT))
	_CONSOLE_CONTEXT_DIRECTORY=$_CONF_APPLICATION_DATA_PATH/active
	_CONSOLE_CONTEXT_FILE=$_CONSOLE_CONTEXT_DIRECTORY/context

	_CONSOLE_CONTEXT_ID=$(head -1 $_CONSOLE_CONTEXT_FILE)

	_context_id_is_valid "$_CONSOLE_CONTEXT_ID"

	_CONSOLE_CONTEXT_DESCRIPTION=$(sed -n 2p $_CONSOLE_CONTEXT_FILE)

	export _CONSOLE_CONTEXT_ID _CONSOLE_CONTEXT_DESCRIPTION

	local index=0
	while read _LINE; do
		if [ $index -gt 1 ]; then
			if [ -n "$_LINE" ]; then
				export $_LINE
			fi
		fi
		index=$(($index + 1))
	done <$_CONSOLE_CONTEXT_FILE
}

_console_is_refresh_context() {
	[ -z "$_CONSOLE_CONTEXT_EXPIRATION" ] && return 0

	[ $_CONSOLE_CONTEXT_EXPIRATION -lt $_CURRENT_TIME ] && return 0

	local _read_id=$(basename $(readlink $_CONF_APPLICATION_DATA_PATH/active))
	[ "$_read_id" != "$_CONSOLE_CONTEXT_ID" ] && return 0

	return 1
}

_console_context_write() {
	local opwd=$PWD
	cd $_CONF_APPLICATION_DATA_PATH
	git pull

	mkdir -p $_CONSOLE_CONTEXT_ID

	local is_new=0
	if [ ! -e $_CONSOLE_CONTEXT_ID/context ]; then
		printf '%s\n' "$_CONSOLE_CONTEXT_ID" >$_CONSOLE_CONTEXT_ID/context
		is_new=1
	fi

	if [ -n "$_CONSOLE_CONTEXT_DESCRIPTION" ]; then
		if [ $is_new -eq 1 ]; then
			printf '%s\n' "$_CONSOLE_CONTEXT_DESCRIPTION" >>$_CONSOLE_CONTEXT_ID/context
		else
			$_CONF_GNU_SED -i '2d' $_CONSOLE_CONTEXT_ID/context
			$_CONF_GNU_SED -i "1a $_CONSOLE_CONTEXT_DESCRIPTION" $_CONSOLE_CONTEXT_ID/context
		fi
	fi

	if [ $# -gt 0 ]; then
		for _ARG in "$@"; do
			printf '%s\n' "$_ARG" >>$_CONSOLE_CONTEXT_ID/context
		done
	fi

	rm -f active
	ln -s $_CONSOLE_CONTEXT_ID active

	git add active $_CONSOLE_CONTEXT_ID
	git commit -am "set-context - $_CONSOLE_CONTEXT_ID"
	git push

	cd $opwd
}
