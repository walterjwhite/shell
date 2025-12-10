_list_functions() {
	$_CONF_GNU_GREP -Ph '^_[a-z0-9_]{3,}\(\) {$' $APP_BUILD_OUTPUT_FILE | sed -e 's/().*//' -e 's/ //g' | sort -u
}

_called_functions() {
	$_CONF_GNU_GREP -Pho '_[a-z0-9_]{3,}( |$|\))' $APP_BUILD_OUTPUT_FILE | sed -e 's/ $//' -e 's/)//' | tr ' ' '\n' | sort -u
}

_invalid_functions() {
	$_CONF_GNU_SED -e 's/#.*$//' -e 's/[[:space:]]\+$//' -e 's/^[[:space:]]\+//' $APP_BUILD_OUTPUT_FILE |
		$_CONF_GNU_GREP -Pv '^$' |
		grep -v '^$' |
		grep '\$' |
		$_CONF_GNU_GREP -Po '(^|[[:space:]]|\()_[a-zA-Z0-9_\$\{\}=]{3,}' |
		grep -v '=' |
		grep '\$' |
		$_CONF_GNU_SED -e 's/#.*$//' -e 's/[[:space:]]\+$//' -e 's/^[[:space:]]\+//' |
		$_CONF_GNU_GREP -P '[a-z]+' |
		sort -u
}

_build_has_invalid_function_name() {
	local invalid_functions=$(_invalid_functions)
	local level=_ERROR

	[ -n "$_WARN_ON_ERROR" ] && level=_WARN

	[ -n "$invalid_functions" ] && {
		$level "$APP_BUILD_OUTPUT_FILE has invalid function names: $invalid_functions"
	}
}



_find_duplicate_functions() {
	local duplicated_functions=$($_CONF_GNU_GREP -Po '[_a-zA-Z0-9]{3,}\(\)' $APP_BUILD_OUTPUT_FILE | sed -e 's/()//' | uniq -d | sort -u)
	[ -z "$duplicated_functions" ] && return

	_WARN 'Duplicated functions'
	printf '%s\n' "$duplicated_functions"

	_WARN_ON_ERROR=1 _ERROR 'Duplicated functions are not allowed'
}
