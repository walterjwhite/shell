_time_install() {
	local _source_filename=$(basename $1)

	_require_file "$1"

	local _target_path=$_APPLICATION_DATA_PATH/$_TARGET_APPLICATION_NAME

	mkdir -p $_target_path

	local _target_job_filename=$_target_path/$_source_filename

	if [ -e $_target_job_filename ]; then
		_WARN "Killing any existing processes for $_target_job_filename"

		local _running_processes=$(ps | grep $_source_filename | grep -v grep | awk {'print$1'})
		if [ -n "$_running_processes" ]; then
			_WARN " found $_running_processes, killing"
			kill $_running_processes
		else
			_WARN " no running processes found for $_source_filename"
		fi
	fi

	cp $1 $_target_job_filename

	$_target_job_filename &
	>/dev/null 2>&1

	_INFO "Started $_source_filename $!"
}
