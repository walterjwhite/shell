_APP_DEFAULT_BOOTSTRAP() {
	:
}

_APP_DEFAULT_INSTALL() {
	if [ -n $_USER ]; then
		_SUDO_USER="$USER" _sudo xdg-mime default $1.desktop $2
		return $?
	fi

	xdg-mime default $1.desktop $2
}

_APP_DEFAULT_UNINSTALL() {
	:
}

_APP_DEFAULT_IS_INSTALLED() {
	:
}

_APP_DEFAULT_ENABLED() {
	return 0
}
