_call() {
	local function_name=$1

	type $function_name >/dev/null 2>&1 || {
		_DEBUG "${function_name} does not exist"

		return 255
	}

	[ $# -gt 1 ] && {
		shift
		$function_name "$@"
		return $?
	}

	$function_name
}

_() {
	_reset_indent

	if [ -n "$_EXEC_ATTEMPTS" ]; then
		local attempt=1

		while [ $attempt -le $_EXEC_ATTEMPTS ]; do
			_WARN_ON_ERROR=1 _do_exec "$@" && return

			attempt=$(($attempt + 1))
		done

		_ERROR "Failed after $attempt attempts: $*"
	fi

	_do_exec "$@"
}

_do_exec() {
	local successful_exit_status=0
	if [ -n "$_SUCCESSFUL_EXIT_STATUS" ]; then
		successful_exit_status=$_SUCCESSFUL_EXIT_STATUS

		unset _SUCCESSFUL_EXIT_STATUS
	fi

	_INFO "## $*"
	local exit_status
	if [ -z "$_DRY_RUN" ]; then
		"$@"
		exit_status=$?
	else
		_WARN "using dry run status: $_DRY_RUN"
		exit_status=$_DRY_RUN
	fi

	if [ $exit_status -ne $successful_exit_status ]; then
		if [ -n "$_ON_FAILURE" ]; then
			$_ON_FAILURE
			return
		fi

		if [ -z "$_WARN_ON_ERROR" ]; then
			_ERROR "Previous cmd failed: $* - $exit_status"
		else
			unset _WARN_ON_ERROR
			_WARN "Previous cmd failed: $* - $exit_status"
			_ENVIRONMENT_FILE=$(_mktemp error) _environment_dump

			return $exit_status
		fi
	fi
}
