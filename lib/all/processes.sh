




_restrict_to_single_process() {
	_has_other_instances && {
		_ERROR "$_APPLICATION_CMD is restricted to a single instance and another instance is running"
	}

	_setup_app_pipe
}

_has_other_instances() {
	find $_APPLICATION_CMD_DIR -maxdepth 1 -type p ! -name $$ 2>/dev/null | grep -qm1 '.'
}

_setup_app_pipe() {
	_APPLICATION_PIPE=$_APPLICATION_CMD_DIR/$$
	_APPLICATION_PIPE_DIR=$(dirname $_APPLICATION_PIPE)

	mkdir -p $_APPLICATION_PIPE_DIR
	mkfifo $_APPLICATION_PIPE

	_defer _cleanup_app_pipe
}

_cleanup_app_pipe() {
	rm -rf $_APPLICATION_PIPE_DIR
}

_kill_all() {
	_do_kill_all $_APPLICATION_PIPE_DIR
}

_kill_all_group() {
	_do_kill_all $_APPLICATION_CONTEXT_GROUP
}

_do_kill_all() {
	for _EXISTING_APPLICATION_PIPE in $(find $1 -type p -not -name $$); do
		_kill $(basename $_EXISTING_APPLICATION_PIPE)
	done
}

_kill() {
	_WARN "Killing $1"
	kill -TERM $1
}

_list() {
	_list_pid_infos $_APPLICATION_PIPE_DIR
}

_list_group() {
	_list_pid_infos $_APPLICATION_CONTEXT_GROUP
}

_list_pid_infos() {
	_INFO "Running processes:"

	_EXECUTABLE_NAME_SED_SAFE=$(_sed_safe $0)

	for _EXISTING_APPLICATION_PIPE in $(find $1 -type p -not -name $$); do
		_list_pidinfo
	done
}

_child_pids() {
	_require "$1" "pid"
	pgrep -P $1
}

_kill_process_and_children() {
	kill -9 $(_child_pids $1) 2>/dev/null
	kill -9 $1
}
