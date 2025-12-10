lib io/path.sh

_GET_SEARCH_GIT_SCOPE() {
	_GIT_WARN=1 _get_project_directory && {
		_SEARCH_SCOPE=.
		return
	}

	_in_path "$_PROJECT_BASE_PATH" && {
		_SEARCH_SCOPE=recursive
		return
	}

	_in_path "$_CONF_DATA_PATH" && {
		_SEARCH_SCOPE=recursive
		return
	}

	_SEARCH_SCOPE=all
}

_SEARCH_GIT_WD() {
	[ $_CONF_SEARCH_CWD_ONLY -eq 0 ] && unset _GIT_NO_INIT_PROJECT_DIRECTORY

	[ $_SEARCH_RECURSIVE ] || _DETAIL "Searching $_SEARCH_FUNCTION @ $_PROJECT: $*"
	_SEARCH_${_SEARCH_FUNCTION_NAME} "$@"
}

_SEARCH_GIT_RECURSIVE() {
	_CONF_INSTALL_NO_PAGER=$_CONF_SEARCH_RECURSIVE_PAGER

	_SEARCH_RECURSIVE=1
	[ -z "$_SEARCH_PATH" ] && _SEARCH_PATH=.

	_SEARCH_SCOPE=. find $_SEARCH_PATH \( -type d -or -type f \) -name '.git' -execdir search "$@" \;
}

_SEARCH_GIT_ALL() {
	if [ -z "$_PROJECT_BASE_PATH" ] && [ -z "$_CONF_DATA_PATH" ]; then
		_SEARCH_PATH="."
	else
		_SEARCH_PATH="$_PROJECT_BASE_PATH $_CONF_DATA_PATH"
	fi

	_SEARCH_GIT_RECURSIVE "$@"
}
