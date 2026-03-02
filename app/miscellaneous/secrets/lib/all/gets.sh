secrets_gets() {
  . __LIBRARY_PATH__/__APPLICATION_NAME__/provider/$conf_secrets_provider/get.sh

  local secret_key_prefix="$1"
  shift

  local _index=1
  for secret_key_name in "$@"; do
    secrets_get $secret_key_prefix $secret_key_name

    _secrets_wait_between_get $_index $#
    _index=$(($_index + 1))
  done
}

_secrets_wait_between_get() {
  [ $1 -ge $2 ] && return

  _stdin_continue_if "Continue?" "Y/n" || exit_with_error "not continuing"
}
