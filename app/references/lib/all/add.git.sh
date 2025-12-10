_is_git() {
	printf '%s' "$1" | $_CONF_GNU_GREP -Pc "^git@(localhost|github.com|gitlab.com)|https://gist.github.com"
}

_do_git() {
	_REFERENCE_PATH=$_KEY/git/$_REFERENCE_NAME
	_prepare

	git submodule add "$1" $_REFERENCE_PATH

	_GIT_PATH="$_GIT_PATH .gitmodules"
}
