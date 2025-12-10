_beep() {
	beep $1 &
}

_sudo_precmd() {
	_beep "$_CONF_LOG_SUDO_BEEP_TONE"
}
