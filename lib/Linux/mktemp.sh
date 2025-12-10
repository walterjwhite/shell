_mktemp() {
	local suffix=$1
	[ -n "$suffix" ] && suffix=".$suffix"

	local sudo_prefix
	[ -n "$_SUDO_USER" ] && sudo_prefix=_sudo

	$sudo_prefix mktemp -${_MKTEMP_OPTIONS}t ${_APPLICATION_NAME}.${_APPLICATION_CMD}${suffix}.XXXXXXXX
}
