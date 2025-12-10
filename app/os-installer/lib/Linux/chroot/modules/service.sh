_PATCH_SERVICE() {
	[ $# -eq 0 ] && {
		_WARN 'No service configuration files provided'
		return 1
	}

	local service_line
	$_CONF_GNU_GREP -Pvh '^($|#)' "$@" | while read service_line; do
		[ -z "$service_line" ] && {
			_WARN "service_line was empty"
			continue
		}

		_SERVICE_$_CONF_OS_INSTALLER_INIT $service_line
	done
}
