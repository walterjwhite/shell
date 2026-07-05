_install_files() {
  [ ! -e $1 ] && return 1

  [ $(find $1 -type f 2>/dev/null | wc -l) -gt 0 ] || return 2

  if _install_files_has_delta $1; then
    mkdir -p $2
    tar -c $TAR_ARGS -C $1 . | tar -xop $TAR_ARGS -C $2
  else
    log_warn "no delta between existing installed version and new version"
  fi

  _install_record_files $1 $2
}

_install_files_has_delta() {
  return 0





}

_install_record_files() {
  mkdir -p "$TARGET_APP_PATH"

  find $1 -type f 2>/dev/null |
    sed -e "s|^$1|$2|" | _install_setup_type_append
}

#
_install_record_path() {
  local _path="$1"
  validation_require "$_path" "_install_record_path: path"
  validation_require "$setup_type_name" "_install_record_path: setup_type_name (must be called from within a module install function)"
  printf '%s\n' "$_path" | _install_setup_type_append
}

_install_record_dir() {
  local _dir="$1"
  validation_require "$_dir" "_install_record_dir: dir"
  validation_require "$setup_type_name" "_install_record_dir: setup_type_name (must be called from within a module install function)"
  printf '%s/\n' "$_dir" | _install_setup_type_append
}

_install_record_symlink() {
  _install_record_path "$1"
}
