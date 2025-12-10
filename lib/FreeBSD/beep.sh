_beep() {
	[ -e /dev/speaker ] || return

	printf '%s' "$@" >/dev/speaker 2>/dev/null &
}

_sudo_precmd() {
	_beep $_CONF_LOG_SUDO_BEEP_TONE
}
