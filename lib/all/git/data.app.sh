lib time.sh

_git_save() {
	local _message="$1"
	shift

	if [ -n "$_PROJECT_PATH" ]; then
		cd $_PROJECT_PATH
	fi

	git add $@ 2>/dev/null
	git commit $@ -m "$_message"

	_has_remotes=$(git remote | wc -l)
	if [ "$_has_remotes" -gt "0" ]; then
		git push
	fi
}

_git_init() {
	local project_identifier=$_APPLICATION_NAME

	[ -n "$1" ] && project_identifier=$1

	_PROJECT_PATH=$_CONF_DATA_PATH/$project_identifier
	_SYSTEM=$(head -1 /usr/local/etc/walterjwhite/system 2>/dev/null)

	if [ -n "$_SYSTEM" ]; then
		_PROJECT=data/$_SYSTEM/$USER/$project_identifier
	else
		_PROJECT=data-$project_identifier
	fi

	if [ ! -e $_PROJECT_PATH/.git ]; then
		_DETAIL "initializing git @ $_PROJECT_PATH"
		_timeout $_CONF_GIT_CLONE_TIMEOUT _git_init git clone "$_CONF_GIT_MIRROR/$_PROJECT" $_PROJECT_PATH || {
			[ -z "$_WARN_ON_ERROR" ] && _ERROR "Unable to initialize project"

			_WARN "Initialized empty project"
			git init $_PROJECT_PATH
		}
	fi

	cd $_PROJECT_PATH
}
