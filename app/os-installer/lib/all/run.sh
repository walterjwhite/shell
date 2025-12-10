_run() {
	_INFO "$*"

	local run_file=${OS_INSTALLER_EXEC_DIR}/$1
	[ -e $run_file ] && {
		_WARN "$* already run, skipping"
		return
	}

	mkdir -p ${OS_INSTALLER_EXEC_DIR}
	touch $run_file
	"$@"
}
