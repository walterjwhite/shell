patch_link() {
  _module_find_callback _link_do
}

_link_do() {
  . $1

  for _target in $targets; do
    log_detail "ln -sf $path -> $_target"

    local parent=$(dirname $_target)
    if [ ! -e $path ]; then
      log_warn "$path does NOT exist"
      continue
    elif [ ! -e $parent ]; then
      mkdir -p $parent
    fi

    ln -sf $path $_target
  done

  unset _target path targets
}
