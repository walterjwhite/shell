_CONSOLE_GET() {
	_console_read_context

	_INFO "Context: $_CONSOLE_CONTEXT_ID | $_CONSOLE_CONTEXT_DESCRIPTION"

	[ $(wc -l <$_CONSOLE_CONTEXT_FILE) -le 2 ] && return

	_DETAIL "Context env:"
	sed 1,2d $_CONSOLE_CONTEXT_FILE
}
