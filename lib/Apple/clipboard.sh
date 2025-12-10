_clipboard_get() {
	pbpaste
}

_clipboard_clear() {
	pbcopy </dev/null
}

_clipboard_put() {
	cat - | pbcopy $1
}
