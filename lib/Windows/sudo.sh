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
  local sudo_return_status=$?
  unset sudo_options

  return $sudo_return_status
}

sudo_is_validation_required() {
  [ -n "$sudo_user" ] && {
    [ "$sudo_user" = "$USER" ] && return 1

    sudo_options="$sudo_options /user:$sudo_user"
    return 0
  }

  _sudo_is_administrator && return 1

  return 0
}

_sudo_is_administrator() {
  net session >/dev/null 2>&1
}

sudo_ensure_administrator() {
  _sudo_is_administrator && return

  log_info "enter administrator password to run this program as administrator"

  sudo_run "$0" "$@"
  exit $?
}

sudo_ensure_not_administrator() {
  _sudo_is_administrator || return

  exit_with_error "$0 cannot be run as administrator"
}

sudo_ensure_root() {
  sudo_ensure_administrator "$@"
}

sudo_ensure_not_root() {
  sudo_ensure_not_administrator "$@"
}

sudo_precmd() {
  :
}
