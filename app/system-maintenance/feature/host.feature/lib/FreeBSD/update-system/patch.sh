_checkrestart() {
	_INFO "checkrestart - start"
	_ checkrestart -H $_CHECKRESTART_OPTIONS

	local service_options
	if [ -n "$_JAIL_NAME" ]; then
		service_options="-j $_JAIL_NAME"
	fi

	local check_restart_service
	for check_restart_service in $(checkrestart -H $_CHECKRESTART_OPTIONS | awk {'print$4'} | sort -u); do
		if [ -e /etc/rc.d/$check_restart_service ] || [ -e /usr/local/etc/rc.d/$check_restart_service ]; then
			_WARN "restarting $check_restart_service"
			service $service_options $check_restart_service restart
		else
			_WARN "$check_restart_service is not a service, but a cmd, manually restart"
		fi
	done

	if [ $(checkrestart -H $_CHECKRESTART_OPTIONS | wc -l) -gt 0 ]; then
		_WARN "checkrestart - restart system / services *REQUIRED*"
		_REBOOT_REQUIRED=$(printf 'checkrestart - restart system / services *REQUIRED*\n%s\n%s\n' "checkrestart -H $_CHECKRESTART_OPTIONS" "$(checkrestart -H $_CHECKRESTART_OPTIONS)")
		_reboot
	fi
}

_patch_be() {
	_INFO "$SYSTEM_UPDATES updates available"

	if [ -z "$_LAST_SEQUENCE" ]; then
		_LAST_SEQUENCE=$(seq -w 0 1 $_CONF_SYSTEM_MAINTENANCE_MAX_PATCHES | head -1)
	else
		_LAST_SEQUENCE=$(seq -w $_LAST_SEQUENCE 1 $_CONF_SYSTEM_MAINTENANCE_MAX_PATCHES | sed 1d | head -1)
	fi

	_SYSTEM_BE_WITH_SEQUENCE="$_SYSTEM_BE.$_LAST_SEQUENCE"

	_LAST_SEQUENCE_FILE=$_JAIL_PATH/usr/local/etc/walterjwhite/patches/$_LAST_SEQUENCE
	if [ -n "$_DRY_RUN" ]; then
		_INFO "printf '%s\n' \"$SYSTEM_UPDATES\" > $_LAST_SEQUENCE_FILE"
	else
		printf '%s\n' "$SYSTEM_UPDATES" >$_LAST_SEQUENCE_FILE
	fi

	_create_be $_SYSTEM_BE_WITH_SEQUENCE
}

_patch() {
	_DETAIL "$_CONF_LOG_HEADER"
	_DETAIL "inspecting"

	_be

	_wait_network

	_INFO "checking if additional updates are available"

	_has_updates || {
		_INFO "no updates available"
		printf '\n\n'
		return
	}

	_WARN "[$SYSTEM_UPDATES] Updates detected"
	_patch_be

	_INFO "completed patching"
	printf '\n\n'
}
