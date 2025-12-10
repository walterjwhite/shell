lib ./env.sh
lib ./secrets.sh


_application_runner() {
	_RUNNER=$_CONF_APPLICATION_LIBRARY_PATH/action/run/${_APPLICATION_TYPE}.sh

	[ ! -e $_RUNNER ] && _ERROR "Application Runner does not exist, $_RUNNER"

	. $_RUNNER

	_run_init_env
	_run_init_secrets

	. .application/$_APPLICATION_TYPE
	_run "$@"
}

_run() {
	_defer _run_cleanup

	_LANGUAGE_NAME=$(printf '%s' $_LANGUAGE | tr '[:lower:]' '[:upper:]')
	_INFO "running $_LANGUAGE_NAME"

	_call _RUN_${_LANGUAGE_NAME}_INIT "$@"
	_run_new_instance

	_call _RUN_${_LANGUAGE_NAME} "$@"

	[ -z "$_DEV_NOTAIL" ] && {
		_colored_tail &
		_TAIL_PID=$!
	}

	_notify_running

	_wait_for

	[ -n "$_DEV_OPEN_LOG" ] && _open_log
}

_run_cleanup() {
	_INFO "run cleaning up"
	[ -n "$_TAIL_PID" ] && _kill_process_and_children $_TAIL_PID 2>/dev/null
	[ -n "$_NOTIFY_PID" ] && _kill_process_and_children $_NOTIFY_PID 2>/dev/null

	kill -9 $_RUN_PID 2>/dev/null

	[ -e $_RUN_INSTANCE_DIR ] && rm -rf $_RUN_INSTANCE_DIR
}

_run_new_instance() {
	[ -z "$_DEV_NEW" ] && return 1

	_RUN_INSTANCE_DIR=$(_MKTEMP_OPTIONS=d _mktemp)

	_INFO "creating new instance in $_RUN_INSTANCE_DIR"

	_call _${_LANGUAGE_NAME}_NEW_INSTANCE
}

_notify_running() {
	[ -z "$_NOTIFY" ] && return 1
	_setup_app_pipe

	_call _${_LANGUAGE_NAME}_IS_RUNNING


	printf '%s\n' "started" >$_APPLICATION_PIPE &
	_NOTIFY_PID=$!
}

_wait_for() {
	[ -z "$_RUN_PID" ] && return 1

	ps -p $_RUN_PID >/dev/null 2>&1
	wait $_RUN_PID
}
