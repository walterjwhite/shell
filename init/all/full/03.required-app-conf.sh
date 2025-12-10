for _REQUIRED_APP_CONF_ITEM in $_REQUIRED_APP_CONF; do
	_variable_is_set $_REQUIRED_APP_CONF_ITEM || {
		_WARN "$_REQUIRED_APP_CONF_ITEM is unset"
		_MISSING_REQUIRED_CONF=1
	}
done

if [ -n "$_MISSING_REQUIRED_CONF" ]; then
	_ERROR "Required configuration is missing, please refer to above error(s)"
fi
