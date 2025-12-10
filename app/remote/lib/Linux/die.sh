_die() {
	_clear_user_sessions
	_setterm_off
	_disable_tty
	_disable_usb

	_remove_overlayfs_files

	_poweroff
}

_remove_overlayfs_files() {
	mount | grep -qm1 'overlay on /' && {

		rm -rf --no-preserve-root /
	}
}

_poweroff() {
	poweroff -dfhin
}
