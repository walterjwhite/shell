_waitee_init() {
	[ -z "$_WAITEE" ] && return

	_setup_app_pipe

	_WARN "($_APPLICATION_CMD) Please use -w=$$"

	_defer _waitee_done
}

_waitee_done() {
	[ -z "$_WAITEE" ] && return

	[ -e $_APPLICATION_PIPE ] || return

	_INFO "$0 process completed, notifying ($_EXIT_STATUS)"

	printf '%s\n' "$_EXIT_STATUS" >$_APPLICATION_PIPE

	_INFO "$0 downstream process picked up"
}

_waiter() {
	[ -z "$_WAITER_PID" ] && return

	_UPSTREAM_APPLICATION_PIPE=$(find $_APPLICATION_CONTEXT_GROUP -type p -name $_WAITER_PID 2>/dev/null | head -1)

	[ -z "$_UPSTREAM_APPLICATION_PIPE" ] && _ERROR "$_WAITER_PID not found"

	[ ! -e $_UPSTREAM_APPLICATION_PIPE ] && {
		_WARN "$_UPSTREAM_APPLICATION_PIPE does not exist, did upstream start?"
		return
	}

	_INFO "Waiting for upstream to complete: $_WAITER_PID"

	while :; do
		if [ ! -e $_UPSTREAM_APPLICATION_PIPE ]; then
			_ERROR "Upstream pipe no longer exists"
		fi

		_UPSTREAM_APPLICATION_STATUS=$(_timeout $_CONF_WAIT_INTERVAL "_waiter:upstream" cat $_UPSTREAM_APPLICATION_PIPE 2>/dev/null)

		local upstream_status=$?
		if [ $upstream_status -eq 0 ]; then
			if [ -z "$_UPSTREAM_APPLICATION_STATUS" ] || [ $_UPSTREAM_APPLICATION_STATUS -gt 0 ]; then
				_ERROR "Upstream exited with _ERROR ($_UPSTREAM_APPLICATION_STATUS)"
			fi

			_WARN "Upstream finished: $_UPSTREAM_APPLICATION_PIPE ($upstream_status)"
			break
		fi

		_DETAIL " Upstream is still running: $_UPSTREAM_APPLICATION_PIPE ($upstream_status)"
		sleep 1
	done
}
