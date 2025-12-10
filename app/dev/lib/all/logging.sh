lib ./colored-tail.sh
lib sed.sh

_capture_env() {
	printf '# run: %s:%s\n' "$(date)" "$PWD" >$_RUN_LOG_FILE
	printf '# git: %s:%s\n' "$(gcb)" "$(git-head)" >>$_RUN_LOG_FILE
	printf '# cmdline: %s\n' "$@" >>$_RUN_LOG_FILE
	printf '# env - start\n' >>$_RUN_LOG_FILE
	env | _sed_remove_nonprintable_characters >>$_RUN_LOG_FILE
	printf '# env - end\n' >>$_RUN_LOG_FILE
}

_setup_log() {
	_RUN_LOG_FILE=.log/$(date +%Y.%m.%d.%H.%M.%S)
	mkdir -p $(dirname $_RUN_LOG_FILE)
}

_open_log() {
	less +G $_RUN_LOG_FILE
}
