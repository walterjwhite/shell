_on_network() {
	local gateway=$(route -4n | grep UG | awk {'print$2'})
	[ -z "$gateway" ] && return 1

	ping -q4c1 -w1 $gateway >/dev/null 2>&1
}

_restart_network_services() {
	local network_service
	for network_service in $(find /etc/init.d -type l -name 'net.*'); do
		$network_service restart
	done
}
