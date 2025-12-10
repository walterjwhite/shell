_unused_functions() {
	local called_functions=$(_called_functions | tr '\n' '|' | sed -e 's/^/(/' -e 's/|$//' -e 's/$/)/')

	_list_functions | $_CONF_GNU_GREP -Pv "^${called_functions}$"
}
