_clipboard_get() {
  wl-paste
}

_clipboard_clear() {
  wl-copy </dev/null
}

_clipboard_put() {
  cat - | wl-copy
}
