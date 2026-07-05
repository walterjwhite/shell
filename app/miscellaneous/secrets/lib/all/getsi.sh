secrets_getsi() {
  . $APP_PATH/provider/$conf_secrets_provider/get.sh

  while :; do
    _stdin_read_if "Key Name" _KEY_NAME
    [ -z "$_KEY_NAME" ] && {
      log_warn "key_name is empty, exiting"
      exit
    }

    secrets_get "$@" $_KEY_NAME
    unset _KEY_NAME
  done
}
