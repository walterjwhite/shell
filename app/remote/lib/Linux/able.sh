_enable_system() {
	_enable_tty
	_enable_usb
	_setterm_on
}

_disable_system() {
	_clear_user_sessions

	_disable_tty
	_disable_usb

	_setterm_off
}
