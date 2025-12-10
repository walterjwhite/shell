_contains_argument() {
	local arg_key=$1
	shift

	for _ARG in "$@"; do
		case $_ARG in
		$arg_key)
			return 0
			;;
		esac
	done

	return 1
}

_require() {
	local level=_ERROR

	if [ -z "$1" ]; then
		[ -n "$_WARN_ON_ERROR" ] && level=_WARN

		$level "$2 required $_REQUIRE_DETAILED_MESSAGE" $3
		return 1
	fi

	unset _REQUIRE_DETAILED_MESSAGE
}

_value_in() {
	local level=_ERROR
	[ -n "$_WARN_ON_ERROR" ] && level=_WARN

	printf '%s\n' "$1" | $_CONF_GNU_GREP -Pcq "^($2)$" || $level "$1 is not in ^($2)$"
}
