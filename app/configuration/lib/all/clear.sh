_CONFIGURE_CLEAR() {
	:
}

_CONFIGURE_CLEAR_PREPARE() {
	:
}

_CONFIGURE_CLEAR_DEFAULT() {
	rm -rf "$_PLUGIN_CONFIGURATION_PATH"

	if [ -z "$_PLUGIN_INCLUDE" ]; then
		return
	fi

	if [ -z "$_PLUGIN_CONFIGURATION_PATH_IS_DIR" ]; then
		local parent=$(dirname "$_PLUGIN_CONFIGURATION_PATH")
		local file
		for file in $_PLUGIN_INCLUDE; do
			rm -f $parent/$file
		done
	fi
}

_CONFIGURE_CLEAR_SYNC() {
	:
}

