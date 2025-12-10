_do_other() {
	_REFERENCE_PATH=$_KEY/other/$_REFERENCE_NAME
	_prepare

	printf '%s\n' "$1" >$_REFERENCE_PATH
}

_reference_name_other() {
	_REFERENCE_NAME=$(printf '%s' "$1" | sha1)
}
