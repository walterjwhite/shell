lib io/file.sh

patch_chmod() {
  _module_find_callback _chmod_do
}

_chmod_do() {
  local required path mode options

  . $1
  [ -z "$required" ] && [ ! -e "$path" ] && {
    log_detail "$path - not found, skipping"
    return
  }

  chmod $options $mode $path
}
