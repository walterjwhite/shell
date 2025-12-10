_interactive_alert() {
	[ -n "$SSH_CLIENT" ] && {
		_WARN "remote connection detected, not beeping"
		_WARN "$*"
		return 1
	}

	say "$*"
}
