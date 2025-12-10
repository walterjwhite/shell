_SEARCH_GIT_LOGS() {
	if [ $# -eq 0 ]; then
		_WARN "Not searching logs as no search argument was provided."
		return
	fi

	for _ARG in "$@"; do
		case $_ARG in
		-i)
			_OPTIONS="${_OPTIONS:+$_OPTIONS }$_ARG"
			;;
		*)
			if [ -n "$_LOGS_SEARCH" ]; then
				_WARN "Excluding arg: $_ARG"
				continue
			fi

			_LOGS_SEARCH="$_ARG"
			;;
		esac
	done

	if [ "$_SEARCH_ALL_BRANCHES" ]; then
		_search_git_logs_all
		return
	fi

	_search_git_logs_do
}

_search_git_logs_do() {
	git log $_SEARCH_BRANCH $_OPTIONS --grep="$_LOGS_SEARCH"
}

_search_git_logs_all() {
	for _SEARCH_BRANCH in $(git branch); do
		_DETAIL "Searching logs in $_SEARCH_BRANCH"
		_search_logs_do
	done
}
