lib git/data.app.sh

cfg git

_is_unsupported_platform() {
	[ -z "$_PLUGIN_CONFIGURATION_PATH" ]
}

_is_feature_disabled() {
	_variable_is_set ${_EXTENSION_FUNCTION_NAME}_DISABLED
}

_CONFIGURE_ACTION() {
	_is_unsupported_platform && {
		_WARN "unsupported on $_PLATFORM"
		return 1
	}

	_is_feature_disabled && {
		_WARN "disabled"
		return 2
	}

	if [ -n "$_PLUGIN_NO_ROOT_USER" ] && [ "$USER" = "root" ]; then
		_WARN "plugin does not support root user"
		return 2
	fi

	_CONFIGURE_$_ACTION || return 1

	_INFO "$_ACTION"

	_call _CONFIGURE_${_EXTENSION_FUNCTION_NAME}_${_ACTION}_PRE
	_CONFIGURE_${_ACTION}_PREPARE

	_call _CONFIGURE_${_EXTENSION_FUNCTION_NAME}_${_ACTION} || _CONFIGURE_${_ACTION}_DEFAULT
	_call _CONFIGURE_${_EXTENSION_FUNCTION_NAME}_${_ACTION}_POST
	_call _CONFIGURE_${_ACTION}_POST
}
