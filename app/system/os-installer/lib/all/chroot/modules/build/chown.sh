patch_chown() {
  _module_find_callback _chown_do
}

_chown_do() {
  local owner group path options required
  . $1

  [ -z "$required" ] && [ ! -e "$path" ] && {
    log_detail "skipping chown for $path (not found)"
    return
  }

  chown $options $owner:$group $path
}
