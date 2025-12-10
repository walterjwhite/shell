_sudo() {
	[ $# -eq 0 ] && _ERROR 'No arguments were provided to _sudo'

	_sudo_is_required || {
		"$@"
		return
	}

	_require "$_SUDO_CMD" "_SUDO_CMD - $*"

	[ -n "$INTERACTIVE" ] && {
		$_SUDO_CMD -n ls >/dev/null 2>&1 || _sudo_precmd "$@"
	}

	$_SUDO_CMD $sudo_options "$@"
	unset sudo_options
}

_sudo_is_required() {
	[ -n "$_SUDO_USER" ] && {
		[ "$_SUDO_USER" = "$USER" ] && return 1

		sudo_options="$sudo_options -u $_SUDO_USER"
		return 0
	}

	[ "$USER" = "root" ] && return 1

	return 0
}


_is_root() {
	[ "$EUID" -ne 0 ] && return 1

	return 0
}
