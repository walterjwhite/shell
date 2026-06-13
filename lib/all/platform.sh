platform_is_supported() {
  case $APP_PLATFORM_PLATFORM in
  $APP_PLATFORM_PLATFORM)
    return 0
    ;;
  *)
    exit_with_error "please use the appropriate platform application: ($APP_PLATFORM_PLATFORM)"
    ;;
  esac
}
