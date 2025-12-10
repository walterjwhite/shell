lib git/include.sh
lib io/path.sh

_get_project_directory() {
	_PROJECT_PATH=$(git rev-parse --show-toplevel 2>/dev/null)
	local status=$?
	if [ $status -gt 0 ]; then
		unset _PROJECT_PATH
		return $status
	fi

	_PROJECT=$(basename $_PROJECT_PATH)

	return 0
}
