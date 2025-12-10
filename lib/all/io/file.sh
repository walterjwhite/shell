_require_file() {
	_require "$1" filename _require_file

	local level=_ERROR
	[ -n "$_WARN_ON_ERROR" ] && level=_WARN

	if [ ! -e $1 ]; then
		$level "File: $1 does not exist | $2"
		return 1
	fi
}

_readlink() {
	if [ $# -lt 1 ] || [ -z "$1" ]; then
		return 1
	fi

	if [ "$1" = "/" ]; then
		printf '%s\n' "$1"
		return
	fi

	if [ ! -e $1 ]; then
		if [ -z $_MKDIR ] || [ $_MKDIR -eq 1 ]; then
			_sudo mkdir -p $1 >/dev/null 2>&1
		fi
	fi

	readlink -f $1
}

_has_contents() {
	_require_file "$1" "_has_contents:$1"

	[ $(_sudo wc -l <$1) -gt 0 ]
}
