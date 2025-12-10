lib jail.sh

_patch_jails() {
	_LOGGING_CONTEXT=jail
	_INFO "inspecting"

	_ON_JAIL=1
	for _JAIL_PATH in $(_get_jail_paths); do
		_JAIL_VOLUME=$(_get_jail_volume $_JAIL_PATH)

		_JAIL_NAME=$(basename $_JAIL_VOLUME)

		_LOGGING_CONTEXT=jail.$_JAIL_NAME

		_FREEBSD_UPDATE_OPTIONS="-j $_JAIL_NAME"
		_PKG_UPDATE_OPTIONS="-j $_JAIL_NAME"
		_CHECKRESTART_OPTIONS="-j $_JAIL_NAME"

		_CONF_SYSTEM_MAINTENANCE_PATCH_TYPES="freebsd_upgrade userland freebsd"

		_patch
	done
}
