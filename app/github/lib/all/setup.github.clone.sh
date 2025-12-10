_github_setup_clone() {
	_PROJECT_NAME=$(basename $PWD)
	_SOURCE_PROJECT=$PWD

	[ -e .github-project-name ] && _GITHUB_PROJECT_NAME=$(head -1 .github-project-name)

	_GITHUB_PROJECT_SYNC_PATH=$_CONF_APPLICATION_DATA_PATH

	_INFO "##### Staging github sync: $_PROJECT_NAME"

	_PWD=$PWD

	_GITHUB_PROJECT_PATH=$_GITHUB_PROJECT_SYNC_PATH/$_PROJECT

	if [ -e $_GITHUB_PROJECT_PATH ]; then
		_ _continue_if "Remove existing github project $_GITHUB_PROJECT_PATH" "Y/n"
		rm -Rf $_GITHUB_PROJECT_PATH
	fi

	_GITHUB_USERNAME=$(secrets get -out=stdout $_CONF_GITHUB_USERNAME_KEY 2>/dev/null)
	_require "$_GITHUB_USERNAME" "_GITHUB_USERNAME - check secrets key: $_CONF_GITHUB_USERNAME_KEY"
	if [ -n "$_GITHUB_PROJECT_NAME" ]; then
		_GITHUB_PROJECT=ssh://git@github.com:/$_GITHUB_USERNAME/$_GITHUB_PROJECT_NAME
	else
		_GITHUB_PROJECT=ssh://git@github.com:/$_GITHUB_USERNAME/$_PROJECT
	fi

	_NEW=1

	_ git clone $_GITHUB_PROJECT $_GITHUB_PROJECT_PATH
}
