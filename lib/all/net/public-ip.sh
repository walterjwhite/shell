_public_ip() {
	local host
	for host in ifconfig.me ipinfo.io/ip icanhazip.com; do
		_do_fetch_public_ip $host && {
			_INFO $PUBLIC_IP
			return
		}
	done

	_WARN "Unable to determine public IP"
	return 1
}

_do_fetch_public_ip() {
	PUBLIC_IP=$(curl -s $1 | $_CONF_GNU_GREP -Po '[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}')
	if [ -z "$PUBLIC_IP" ]; then
		unset PUBLIC_IP
		return 1
	fi

	return 0
}
