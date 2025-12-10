_SERVICE_INSTALL() {
	service add "$@"
}

_SERVICE_UNINSTALL() {
	service del "$@"
}

_SERVICE_IS_FILE() {
	return 1
}
