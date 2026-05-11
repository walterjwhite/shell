_platform_sub_platform() {
  [ -n "$APP_PLATFORM_SUB_PLATFORM" ] && return $APP_PLATFORM_SUB_PLATFORM

  APP_PLATFORM_SUB_PLATFORM=$(cmd //c systeminfo | grep -i "OS" | sed -e 's/^OS Name://g' -e 's/^[[:space:]]*//g' -e 's/[[:space:]]*$//g')
  return $APP_PLATFORM_SUB_PLATFORM
}
