_get_jail_paths() {
	grep 'path = ' /etc/jail.conf /etc/jail.conf.d -rh 2>/dev/null | awk -F'=' {'print$2'} | tr -d ' ;"' | sort -u
}

_get_jail_volume() {
	zfs list -H | grep "${1}$" | awk {'print$1'}
}

_in_jail() {
	[ $(sysctl -n security.jail.jailed) -eq 1 ] && return 0

	return 1
}
