_remove_unused_functions() {
	local index=0
	while :; do
		local unused_functions=$(_unused_functions)

		[ -z "$unused_functions" ] && break

		_DEBUG "remove function:$index:$unused_functions"

		local unused_function
		for unused_function in $unused_functions; do
			_remove_unused_function $unused_function $APP_BUILD_OUTPUT_FILE
		done

		index=$(($index + 1))
	done
}

_remove_unused_function() {
	local function_start=$(_function_start $1 $2)
	local function_end=$(_function_end $2 $function_start)

	_WARN_ON_ERROR=1 _require "$function_start" function_start || return 1
	_WARN_ON_ERROR=1 _require "$function_end" function_end || return 1

	$_CONF_GNU_SED -i "$function_start,$function_end d" $2
}

_function_start() {
	$_CONF_GNU_GREP -Pnh "^$1\(\) {$" $2 | head -1 | cut -f1 -d:
}

_function_end() {
	awk "NR > $2 { if (\$0 ~ /^\}$/) { print NR; exit } }" $1
}
