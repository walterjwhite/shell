platform_is_supported() {
  local _supported_platforms="$1"
  local _platform

  [ -z "$_supported_platforms" ] && return 0

  for _platform in $_supported_platforms; do
    [ "$APP_PLATFORM_PLATFORM" = "$_platform" ] && return 0
  done

  exit_with_error "platform '$APP_PLATFORM_PLATFORM' is not supported; supported: $_supported_platforms"
}

_get_install_target() {
  local cmd_path=$(command -v $1) || exit_with_error "missing $1"

  case $cmd_path in
  *${HOME}*)
    install_target=USER
    ;;
  *)
    install_target=SYSTEM
    ;;
  esac
}
