_clipboard_get() {
  powershell get-clipboard
}

_clipboard_clear() {
  printf '' | clip
}

_clipboard_put() {
  cat - | clip
}
