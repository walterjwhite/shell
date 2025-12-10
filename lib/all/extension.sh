_run_extensions() {
	[ $extension_path ] || extension_path=$_CONF_APPLICATION_LIBRARY_PATH/provider
	[ ! -e $extension_path ] && return 1

	_increase_indent

	_APPLICATION_NAME_PREFIX=$(printf '%s' $_APPLICATION_NAME | tr '-' '_' | tr '.' '_' | tr '[:lower:]' '[:upper:]')

	for _EXTENSION in $(find $extension_path -type f | sort); do
		_EXTENSION_NAME=$(basename $_EXTENSION | sed -e 's/\.sh$//')

		_EXTENSION_FUNCTION_NAME=$(printf '%s' $_EXTENSION_NAME | tr '-' '_' | tr '.' '_' | tr '[:lower:]' '[:upper:]')
		_EXTENSION_CLEAR_KEY=$(printf '%s' $_EXTENSION_NAME | tr '[:lower:]' '[:upper:]' | tr '-' '_' | tr '.' '_')

		_add_logging_context $_EXTENSION_NAME

		_call _${_APPLICATION_NAME_PREFIX}_BEFORE_EACH

		. $_EXTENSION

		if [ "$#" -eq 0 ]; then
			_${_APPLICATION_NAME_PREFIX}_${_EXTENSION_FUNCTION_NAME}${_EXTENSION_FUNCTION_SUFFIX}
		else
			[ -n "$1" ] && $1
			[ -n "$2" ] && $2
		fi

		_call _${_APPLICATION_NAME_PREFIX}_AFTER_EACH

		_remove_logging_context
		unset _EXTENSION_NAME _EXTENSION_FUNCTION_NAME _EXTENSION_CLEAR_KEY
	done

	_decrease_indent
}

_load_extension() {
	[ $# -lt 1 ] && _ERROR "Extension name is required, ie. firefox"

	local extension_name=$1
	shift

	[ $extension_path ] || extension_path=$_CONF_APPLICATION_LIBRARY_PATH/provider

	local extension_file=$(find $extension_path -type f -name "$extension_name.sh" | head -1)
	_include $extension_file || _ERROR "Unable to load $plugin_name"
}
