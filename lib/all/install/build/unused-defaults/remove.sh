_remove_unused_variables() {
	local index=0
	while :; do
		local unused_variables=$(_unused_variables)

		[ -z "$unused_variables" ] && break

		_DEBUG "remove cfg:$i:$unused_variables"
		local unused_variable
		for unused_variable in $unused_variables; do
			_remove_unused_variable $unused_variable $APP_BUILD_OUTPUT_FILE
		done

		index=$(($index + 1))
	done
}

_remove_unused_variable() {
	_DEBUG "Unused default: $1"
	$_CONF_GNU_SED -i "/^[[:space:]]*: \${$1:=.*}$/d" $2
	$_CONF_GNU_SED -i "/^.*$1=.*$/d" $2
}
