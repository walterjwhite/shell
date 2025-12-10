_CONFIGURE_RESTORE() {
	if [ ! -e $_CONF_APPLICATION_DATA_PATH/$_EXTENSION_NAME ]; then
		_DEBUG "no configuration found"
		return 1
	fi
}

_CONFIGURE_RESTORE_PREPARE() {
	_call _CONFIGURE_${_EXTENSION_FUNCTION_NAME}_CLEAR || _CONFIGURE_CLEAR_DEFAULT

	if [ -n "$_PLUGIN_CONFIGURATION_PATH_IS_DIR" ]; then
		if [ -z "$_PLUGIN_CONFIGURATION_PATH_IS_SKIP_PREPARE" ]; then
			mkdir -p "$_PLUGIN_CONFIGURATION_PATH"
		fi

		return
	fi

	local plugin_parent_dir=$(dirname "$_PLUGIN_CONFIGURATION_PATH")
	local plugin_filename=$(basename "$_PLUGIN_CONFIGURATION_PATH")
	mkdir -p $plugin_parent_dir

	_PLUGIN_CONFIGURATION_PATH="$plugin_parent_dir"
}

_CONFIGURE_RESTORE_DEFAULT() {
	tar -cp $_TAR_ARGS -C $_CONF_APPLICATION_DATA_PATH/$_EXTENSION_NAME . | tar -xp $_TAR_ARGS -C "$_PLUGIN_CONFIGURATION_PATH"
}

_CONFIGURE_RESTORE_SYNC() {
	:
}
