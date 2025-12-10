_unused_variables() {
	local used_variables=$(_used_variables $APP_BUILD_OUTPUT_FILE | tr '\n' '|' | sed -e 's/^/(/' -e 's/|$//' -e 's/$/)/')

	_list_variables $APP_BUILD_OUTPUT_FILE | $_CONF_GNU_GREP -Pv "^${used_variables}$"
}
