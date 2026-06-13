_clipboard_get() {
  clip.exe -o
}

_clipboard_clear() {
  printf '' | clip.exe
}

_clipboard_put() {
  clip.exe
}
