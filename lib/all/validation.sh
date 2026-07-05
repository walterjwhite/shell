_validation_contains_argument() {
  local _arg_key=$1
  shift

  local _arg
  for _arg in "$@"; do
    case $_arg in
    $_arg_key)
      return 0
      ;;
    esac
  done

  return 1
}

validation_require() {
  [ -n "$1" ] && return

  [ -n "$warn_on_error" ] && {
    log_warn "$2 required $required_message" $3
    return 1
  }

  exit_with_error "$2 required $required_message" $3
}

_validation_value_in() {
  printf '%s\n' "$1" | $GNU_GREP -Pcq "^($2)$" && return

  [ -n "$warn_on_error" ] && {
    log_warn "$1 is not in ^($2)$"
    return 1
  }

  exit_with_error "$1 is not in ^($2)$"
}
