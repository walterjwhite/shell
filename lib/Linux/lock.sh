_lock() {
  local _locktime_timeout=$1
  shift

  local _lock_file=$1
  shift

  if [ "$#" -eq 0 ]; then
    exit_with_error "lock requires at least 3 arguments, timeout (1), lock file (2), and cmd (3)"
  fi

  flock -w $_locktime_timeout $_lock_file "$@"
}
