_init_net() {
	_determine_network_interface

	ifconfig $OS_INSTALLER_NET_DEV up

	killall dhclient 2>/dev/null

	dhclient $OS_INSTALLER_NET_DEV >/dev/null 2>&1 || _ERROR "Unable to bring up $OS_INSTALLER_NET_DEV"

	mkdir -p /tmp/bsdinstall_etc
	resolvconf -u

	ssh-keygen -R $_CONF_OS_INSTALLER_PACKAGE_CACHE
}

_determine_network_interface() {
	[ -n "$OS_INSTALLER_NET_DEV" ] && return

	OS_INSTALLER_NET_DEV=$(ifconfig -l | tr ' ' '\n' | grep -v ^lo | grep -v ^pf | sort -u | head -1)
}
