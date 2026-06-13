sudo_run() {
  [ $# -eq 0 ] && exit_with_error 'no arguments were provided to sudo_run'

  sudo_is_validation_required || {
    "$@"
    return
  }

  validation_require "$_SUDO_CMD" "sudo_cmd - $*"

  [ -n "$interactive" ] && {
    $_SUDO_CMD -n ls >/dev/null 2>&1 || sudo_precmd "$@"
  }

  $_SUDO_CMD $sudo_options "$@"
  unset sudo_options
}

sudo_is_validation_required() {
  [ -n "$sudo_user" ] && {
    [ "$sudo_user" = "$USER" ] && return 1

    sudo_options="$sudo_options -u $sudo_user"
    return 0
  }

  [ "$USER" = "root" ] && return 1

  return 0
}

_sudo_is_root() {
  [ "$EUID" -eq 0 ]
}

sudo_ensure_root() {
  [ "$EUID" -eq 0 ] && return

  log_info "enter sudo password to run this program as root"

  sudo_run $0 "$@"
  exit $?
}

sudo_ensure_not_root() {
  [ "$EUID" -ne 0 ] && return

  exit_with_error "$0 cannot be run as root"
}
