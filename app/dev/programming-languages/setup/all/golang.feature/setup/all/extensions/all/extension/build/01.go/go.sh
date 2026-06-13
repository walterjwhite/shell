lib feature:.

_go_build_all() {
  local error_count=0
  for _ELEMENT in "$@"; do
    _go_build || error_count=$(($error_count + 1))
  done

  return $error_count
}

_go_build() {
  local command_directory=$(readlink -f $_ELEMENT)
  local app_name=$(basename $command_directory)

  cd $command_directory
  log_info "building $app_name"

  go_build_errors=0
  _go_exec dependencies mod_tidy build_do fix lint vet test

  cd $ORIGINAL_PWD

  return $go_build_errors
}

_go_exec() {
  for go_function in "$@"; do
    go_$go_function || {
      log_warn "function $go_function produced error(s) - $?"
      go_build_errors=$(($go_build_errors + 1))
    }
  done
}

_go_build_cleanup() {
  find /tmp -maxdepth 1 -mindepth 1 \
    -name 'go-build*' -or -name 'cgo*' -or -name 'cc*' -or -name 'golangci*' \
    -exec rm -rf {} + 2>/dev/null
}

readonly ORIGINAL_PWD=$PWD
exit_defer _go_build_cleanup

unset GOPATH

if [ "$#" -eq "0" ]; then
  _go_build_all $(extension_find_dirs_containing)
else
  _go_build_all "$@"
fi
