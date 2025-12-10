_SEARCH_GIT_CONTENTS() {
	if [ $# -eq 0 ]; then
		_WARN "Not searching contents as no search argument was provided."
		return
	fi

	for _ARG in "$@"; do
		case $_ARG in
		--before=*)
			shift
			;;
		--after=*)
			shift
			;;
		-i | -v | -l)
			_OPTIONS="${_OPTIONS:+$_OPTIONS }$_ARG"
			shift
			;;
		*)
			break
			;;
		esac
	done

	for _ARG in "$@"; do
		case $_ARG in
		*)
			if [ -n "$_CONTENTS_SEARCH" ]; then
				_WARN "Excluding arg: $_ARG"
				continue
			fi

			_CONTENTS_SEARCH=$(printf "$_ARG" | sed -e 's/^-/\\-/')
			;;
		esac
	done

	: ${_SEARCH_COMMITS:=CURRENT}
	_search_git_contents_get_type

	if [ $_CONF_SEARCH_CONTENTS_RECURSE_SUBMODULES -eq 1 ]; then
		_OPTIONS="${_OPTIONS:+$_OPTIONS }--recurse-submodules"
	fi

	if [ "$_SEARCH_XEDIT" ]; then
		_git_contents_xedit
	elif [ "$_SEARCH_EDIT" ]; then
		_git_contents_edit
	elif [ "$_SEARCH_FILES" ]; then
		_git_contents_files
	else
		_git_contents_search
	fi
}

_git_contents_search() {
	_OPTIONS="${_OPTIONS:+$_OPTIONS }-n"
	_GIT_CONTENTS_SEARCH_$_SEARCH_COMMITS
}

_GIT_CONTENTS_SEARCH_CURRENT() {
	git grep -I $_OPTIONS "$_CONTENTS_SEARCH" $_SEARCH_BRANCH
}

_GIT_CONTENTS_SEARCH_ANY() {
	git rev-list --all | xargs _GIT_CONTENTS_SEARCH_CURRENT
}

_GIT_CONTENTS_SEARCH_ALL() {
	for _SEARCH_BRANCH in $(git branch); do
		_DETAIL " searching contents in $_SEARCH_BRANCH"
		_GIT_CONTENTS_SEARCH_CURRENT
	done
}

_git_contents_edit() {
	_OPTIONS="${_OPTIONS:+$_OPTIONS }-l"
	$_CONF_SEARCH_EDITOR $(_GIT_CONTENTS_SEARCH_CURRENT)
}

_git_contents_xedit() {
	_OPTIONS="${_OPTIONS:+$_OPTIONS }-l"
	$_CONF_SEARCH_XEDITOR $(_GIT_CONTENTS_SEARCH_CURRENT)
}

_git_contents_files() {
	_OPTIONS="${_OPTIONS:+$_OPTIONS }-l"
	$_CONF_SEARCH_FILE_MANAGER $(dirname $(_GIT_CONTENTS_SEARCH_CURRENT) | sort -u)
}

_search_git_contents_get_type() {
	case $_CONF_SEARCH_CONTENTS_TYPE in
	string)
		_OPTIONS="${_OPTIONS:+$_OPTIONS }-F"
		;;
	regex)
		_OPTIONS="${_OPTIONS:+$_OPTIONS }-G"
		;;
	*)
		_ERROR "Unknown search type: $_CONF_SEARCH_CONTENTS_TYPE"
		;;
	esac
}
