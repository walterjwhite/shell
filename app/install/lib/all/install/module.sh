_install_files() {
  [ ! -e $1 ] && return 1

  [ $(find $1 -type f 2>/dev/null | wc -l) -gt 0 ] || return 2

  if _install_files_has_delta $1; then
    mkdir -p $2
    tar -c $_TAR_ARGS -C $1 . | tar -xop $_TAR_ARGS -C $2
  else
    log_warn "no delta between existing installed version and new version"
  fi

  _install_record_files $1 $2
}

_install_files_has_delta() {
  return 0





}

_install_record_files() {
  mkdir -p "$APP_PLATFORM_LIBRARY_PATH/$target_application_name"

  find $1 -type f 2>/dev/null |
    sed -e "s|^$1|$2|" | _install_setup_type_append
}
