_clipboard_get() {
	_CLIPBOARD_${_CONF_CLIPBOARD_PROVIDER}_GET
}

_clipboard_clear() {
	_CLIPBOARD_${_CONF_CLIPBOARD_PROVIDER}_CLEAR
}

_clipboard_put() {
	_CLIPBOARD_${_CONF_CLIPBOARD_PROVIDER}_PUT
}

_CLIPBOARD_X11_GET() {
	xsel -bo
}

_CLIPBOARD_X11_CLEAR() {
	xsel -bc
}

_CLIPBOARD_X11_PUT() {
	cat - | xsel -bi
}

_CLIPBOARD_WAYLAND_GET() {
	wl-paste
}

_CLIPBOARD_WAYLAND_CLEAR() {
	wl-copy </dev/null
}

_CLIPBOARD_WAYLAND_PUT() {
	cat - | wl-copy
}
