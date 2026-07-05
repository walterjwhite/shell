_secrets_iterate() {
  local _function_name=$1
  shift

  [ "$#" -eq 0 ] && exit_with_error "at least 1 file is required to $_function_name"

  for _ENCRYPTION_SOURCE_FILE in "$@"; do
    _secrets_action_is_valid $_function_name || {
      log_warn "$_function_name is invalid: $_ENCRYPTION_SOURCE_FILE"
      continue
    }

    $_function_name
  done
  unset _function_name
}

_secrets_action_is_valid() {
  case "$_ENCRYPTION_SOURCE_FILE" in
  *.asc | *.gpg)
    [ $1 = "_secrets_decrypt" ]
    ;;
  *)
    [ $1 = "_secrets_encrypt" ]
    ;;
  esac
}
