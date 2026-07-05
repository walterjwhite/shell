_lock_lock() {
  local _locktime_timeout=$1
  shift

  local _lock_file=$1
  shift

  [ "$#" -eq 0 ] && exit_with_error "lock_lock requires at least 3 arguments, timeout (1), lock file (2), and cmd (3)"

  lockf -t "$_locktime_timeout" "$_lock_file" "$@"
}
