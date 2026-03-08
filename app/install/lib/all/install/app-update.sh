_is_latest() {
  [ ! -e $APP_PLATFORM_LIBRARY_PATH/$1/.metadata ] && return 1

  local installed_app_git_url=$(grep APPLICATION_GIT_URL $APP_PLATFORM_LIBRARY_PATH/$1/.metadata 2>/dev/null | cut -f2 -d= | tr -d '"')
  local latest_app_version=$target_application_version
  target_application_installed_version=$(grep APPLICATION_VERSION $APP_PLATFORM_LIBRARY_PATH/$1/.metadata 2>/dev/null | cut -f2 -d= | tr -d '"')

  [ "$latest_app_version" = "$target_application_installed_version" ]
}
