_require_root() {
	[ $(whoami) != "root" ] && _ERROR "Please re-run $0 as root"
}
