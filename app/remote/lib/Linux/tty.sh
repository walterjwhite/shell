_disable_tty() {
	$_CONF_GNU_SED -i 's/^c/#c/' /etc/inittab
	_reload_init
}

_enable_tty() {
	$_CONF_GNU_SED -i 's/^#c/c/' /etc/inittab
	_reload_init
}

_reload_init() {
	kill -hup 1
}
