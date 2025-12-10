_required_arguments() {
	_REQUIRED_ARGUMENTS=$($_CONF_GNU_GREP -P "^_REQUIRED_ARGUMENTS=" "$1")
	[ -z "$_REQUIRED_ARGUMENTS" ] && return 1

	printf '%s\n' "$_REQUIRED_ARGUMENTS" >>$APP_BUILD_OUTPUT_FILE
}

_required_cfg() {
	local required_cfg=$($_CONF_GNU_GREP -Pvh '#.*$' $APP_BUILD_OUTPUT_FILE |
		$_CONF_GNU_GREP -Poh '\$_CONF_[\w_]{3,}' | sed -e 's/^\$//' | sort -u)

	local defaults=$($_CONF_GNU_GREP -Poh '_CONF_[\w]{3,}:?=' $APP_BUILD_OUTPUT_FILE | sed -e 's/^\$//' -e 's/:=$//' -e 's/=$//' | sort -u | tr '\n' '|' | sed -e 's/|$//' -e 's/^/(/' -e 's/$/)/')

	local required_app_conf=$(printf '%s\n' "$required_cfg" | $_CONF_GNU_GREP -Pv "$defaults" | tr '\n' ' ' | sed -e 's/ $//')

	[ -n "$required_app_conf" ] && printf '_REQUIRED_APP_CONF="%s"\n' "$required_app_conf" >>$APP_BUILD_OUTPUT_FILE
}
