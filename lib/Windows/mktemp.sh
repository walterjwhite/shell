_mktemp() {
	local suffix=$1
	[ -n "$suffix" ] && suffix=".$suffix"

	mktemp -${_MKTEMP_OPTIONS}t ${_APPLICATION_NAME}.${_APPLICATION_CMD}${suffix}.XXXXXXXX
}
