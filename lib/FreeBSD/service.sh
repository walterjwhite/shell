_DISABLE_SERVICE() {
	SERVICE_ACTION=stop SERVICE_ENABLED=NO _service "$@"
}

_ENABLE_SERVICE() {
	SERVICE_ACTION=start SERVICE_ENABLED=YES _service "$@"
}

_service() {
	local service
	for service in "$@"; do
		if [ -z "$SYSTEM_INSTALL" ]; then
			service $service one${SERVICE_ACTION}
		fi

		sysrc ${service}_enable=${SERVICE_ENABLED}
	done
}
