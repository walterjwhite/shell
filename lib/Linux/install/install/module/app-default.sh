__APP_DEFAULT_BOOTSTRAP() {
	:
}

__APP_DEFAULT_INSTALL() {
	if [ -n $_USER ]; then
		_SUDO_USER="$USER" _sudo xdg-mime default $1.desktop $2
		return $?
	fi

	xdg-mime default $1.desktop $2
}

__APP_DEFAULT_UNINSTALL() {
	:
}

__APP_DEFAULT_IS_INSTALLED() {
	:
}

__APP_DEFAULT_ENABLED() {
	return 0
}
