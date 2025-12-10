_wait_network() {
	ping -qo -i $_CONF_SYSTEM_MAINTENANCE_NETWORK_BACKOFF_TIME -c $_CONF_SYSTEM_MAINTENANCE_NETWORK_RETRIES $_CONF_SYSTEM_MAINTENANCE_NETWORK_TARGET >/dev/null 2>&1 && {
		_DETAIL "Network is up"
		return
	}

	_ERROR "Unable to get network connection"
}
