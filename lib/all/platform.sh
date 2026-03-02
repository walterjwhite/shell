platform_is_supported() {
  case $APP_PLATFORM_PLATFORM in
  $APP_PLATFORM_PLATFORM)
    return 0
    ;;
  *)
    printf '%s\n' "$APP_PLATFORM_SUPPORTED_PLATFORMS" | tr ' ' '\n' | grep -cqm1 "^$APP_PLATFORM_PLATFORM$" && {
      exit_with_error "please use the appropriate platform application: ($APP_PLATFORM_PLATFORM)"
    }

    exit_with_error "unsupported platform ($APP_PLATFORM_PLATFORM)"
    ;;
  esac
}
