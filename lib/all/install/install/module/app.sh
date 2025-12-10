_APP_BOOTSTRAP() {
	:
}

_APP_INSTALL() {
	_DEPENDENCY=1 app-install $1
}

_APP_UNINSTALL() {
	app-uninstall $1
}

_APP_IS_INSTALLED() {
	[ -e $_CONF_LIBRARY_PATH/$1/.metadata ]
}

_APP_IS_FILE() {
	return 1
}
