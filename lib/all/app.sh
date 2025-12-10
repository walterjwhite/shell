_is_app() {
	[ ! -e .app ] && return 1

	return 0
}
