_CONSOLE_SET() {
	_NEW_CONTEXT_ID=$1
	shift

	_require "$_NEW_CONTEXT_ID" "_NEW_CONTEXT_ID"
	_CONSOLE_CONTEXT_ID=$_NEW_CONTEXT_ID

	unset _CONSOLE_CONTEXT_DESCRIPTION
	if [ $# -gt 0 ]; then
		_CONSOLE_CONTEXT_DESCRIPTION=$1
		shift
	fi

	_console_context_write "$@"

}
