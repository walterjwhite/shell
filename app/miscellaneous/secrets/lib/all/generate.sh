secrets_generate() {
  case $1 in
  pin)
    log_info "generating 4-digit pin"
    shuf -i 1000-9999 -n 1
    return
    ;;
  token)
    log_info "generating 6-digit token"
    shuf -i 100000-999999 -n 1
    return
    ;;
  username)
    log_info "generating 8-character username"
    conf_secrets_password_length=8
    ;;
  wifi-ssid)
    log_info "generating wifi ssid"
    conf_secrets_generate_symbols=0

    [ "$conf_secrets_password_length" -eq "32" ] && conf_secrets_password_length=8
    ;;
  wifi-key)
    log_info "generating wifi key"
    optn_secrets_remove_symbols=":;\""

    [ "$conf_secrets_password_length" -eq "32" ] && conf_secrets_password_length=63
    ;;
  "")
    log_info "generating password"
    ;;
  *)
    exit_with_error "invalid type: $1"
    ;;
  esac

  _secrets_generate_options
  pwgen -s $pwgen_options $conf_secrets_password_length 1
}

_secrets_generate_options() {
  case $conf_secrets_generate_capitalize in
  1)
    _secrets_pass_options -c
    ;;
  0)
    _secrets_pass_options -A
    ;;
  esac

  case $conf_secrets_generate_numerals in
  1)
    _secrets_pass_options -n
    ;;
  0)
    _secrets_pass_options -0
    ;;
  esac

  case $conf_secrets_generate_symbols in
  1)
    _secrets_pass_options -y
    ;;
  esac

  case $conf_secrets_generate_no_ambiguous in
  1)
    _secrets_pass_options -B
    ;;
  esac

  [ -n "$optn_secrets_remove_symbols" ] && _secrets_pass_options "-r $optn_secrets_remove_symbols"
}

_secrets_pass_options() {
  pwgen_options="$pwgen_options $1"
}
