lib git/data.app.sh
lib git/project.directory.sh
lib time.sh

cfg git

_activity_init() {


	_git_init $1
	_ACTIVITY_DIRECTORY=$_PROJECT_PATH/.activity
}

_activity_decade_path() {
	local date_path=$(date +%Y/%m.%B/%d/%H.%M.%S)
	local decade=$(_time_decade)

	printf '%s/%s\n' "$decade" "$date_path"
}
