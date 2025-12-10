_start_ssh() {
	_is_port_in_use 22
	if [ $? -eq 0 ]; then
		_WARN "Unable to start SSHd as it is already running"
	else
		_start_service sshd
		_SSHD_STARTED=1
	fi

	_WARN "IP: $(_IPS)"
}

_stop_ssh() {
	[ -z "$_SSHD_STARTED" ] && return 1

	_stop_service sshd
}
