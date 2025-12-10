_sudo() {
	runas "$@"
}

_is_root() {
	net session >/dev/null 2>&1 || return 1

	return 0
}
