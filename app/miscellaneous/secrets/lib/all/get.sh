lib qr.sh

secrets_get() {
  _secrets_get_key "$@"
  [ -n "$out" ] && conf_secrets_output_function=$out

  case $conf_secrets_output_function in
  wifi)
    secrets_get_wifi "$@"
    ;;
  clipboard | qrcode)
    secrets_output_function_name=$conf_secrets_output_function
    secrets_get_$secrets_output_function_name "$@"
    ;;
  stdout)
    _secrets_get_formatted_stdout
    ;;
  *)
    exit_with_error "invalid output function: $out"
    ;;
  esac
}

_secrets_get_key() {
  [ $# -eq 0 ] && exit_with_error "key name or search pattern is required"

  secrets_get_find "$@"
}

secrets_get_qrcode() {
  [ -z "$secret_value" ] && secret_value=$(secrets_get_stdout)
  _qr_write
}

secrets_get_wifi() {
  local ssid=$(secret_key=$secret_key/ssid secrets_get_stdout 2>/dev/null)
  validation_require "$ssid" ssid

  local encryption_type=$(secret_key=$secret_key/encryption-type secrets_get_stdout 2>/dev/null)
  validation_require "$encryption_type" encryption_type

  local key=$(secret_key=$secret_key/key secrets_get_stdout 2>/dev/null)
  validation_require "$key" key

  local is_hidden=$(secret_key=$secret_key/is-hidden secrets_get_stdout 2>/dev/null)
  secret_value="WIFI:S:$ssid;T:$encryption_type;P:$key;H:$is_hidden;;" secrets_get_qrcode
}
