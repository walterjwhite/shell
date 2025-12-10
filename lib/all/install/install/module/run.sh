_RUN_BOOTSTRAP() {
	:
}

_RUN_INSTALL() {
	sh $1
}

_RUN_UNINSTALL() {
	_WARN "run uninstall - Not implemented"
}

_RUN_IS_INSTALLED() {
	return 1
}

_RUN_IS_FILE() {
	return 0
}
