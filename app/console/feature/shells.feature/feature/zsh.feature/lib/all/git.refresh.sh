_console_pull_is_running() {
	[ -z "$_CONSOLE_PULL_PID" ] && return 1

	ps -p $_CONSOLE_PULL_PID >/dev/null 2>&1 && return 0

	unset _CONSOLE_PULL_PID
	return 1
}

_console_pull_print_output() {
	: ${_CONSOLE_PULL_OUT:=$_CONF_DATA_PATH/console.out}

	[ ! -e $_CONSOLE_PULL_OUT ] && return 1

	[ $(wc -l <$_CONSOLE_PULL_OUT) -gt 0 ] && {
		grep -cqm1 'Already up to date.' $_CONSOLE_PULL_OUT || {
			_INFO "previous pull logs"
			cat $_CONSOLE_PULL_OUT
		}
	}

	rm -f $_CONSOLE_PULL_OUT
}

_console_shall_sync() {
	: ${_CONSOLE_PULL_SYNC_TIME:=$_CONF_DATA_PATH/console.synctime}

	[ ! -e $_CONSOLE_PULL_SYNC_TIME ] && return 0

	local sync_time=$(head -1 $_CONSOLE_PULL_SYNC_TIME)

	local now=$(date +%s)
	local delta=$(($now - $sync_time))

	[ $delta -ge 300 ]
}

_console_pull() {
	cd $_CONSOLE_CONTEXT_DIRECTORY
	git pull >$_CONSOLE_PULL_OUT 2>&1

	date +%s >$_CONSOLE_PULL_SYNC_TIME
}
