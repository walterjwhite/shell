_secrets_get_formatted_stdout() {
  [ -n "$force_interactive" ] && return 1

  secrets_get_stdout | _secrets_format_stdout
}

_secrets_format_stdout() {
  [ -n "$disable_formatting" ] && {
    cat -
    return 0
  }

  local secret_type=$(printf '%s' "$secret_key" | sed -e 's/^.*\///')
  case $secret_type in
  *pin*)
    sed -r -e 's/^.{3}/& /'
    ;;
  *phone*)
    sed -r -e 's/^.{3}/& /' -e 's/^.{7}/& /'
    ;;
  *number* | *account* | *member*)
    sed -r -e 's/^.{4}/& /' -e 's/^.{9}/& /' -e 's/^.{14}/& /' -e 's/^.{19}/& /'
    ;;
  *)
    cat -
    ;;
  esac
}
