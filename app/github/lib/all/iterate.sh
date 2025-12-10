lib git/include.sh
lib git/project.directory.sh
lib ./setup.github.clone.sh

_github_init() {
	[ -z "$_GIT_NO_INIT_PROJECT_DIRECTORY" ] && _get_project_directory


	_github_setup_clone
	if [ $? -gt 0 ]; then
		return 1
	fi

	cd $_GITHUB_PROJECT_PATH
	return 0
}

_github_iterate_main() {
	if [ -z "$_GIT_STATUS_RECURSIVE" ]; then
		_git_in_working_directory || {
			_INFO "Running $_APPLICATION_CMD recursively"

			_GIT_STATUS_RECURSIVE=1
			find . \( -type d -or -type f \) -and -name '.git' -execdir $_APPLICATION_CMD \;
			exit
		}
	fi

	_github_iterate_init
	_github_iterate
}
