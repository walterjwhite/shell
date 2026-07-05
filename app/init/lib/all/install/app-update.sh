_is_latest() {
  [ ! -e "$TARGET_APP_PATH/.metadata" ] && return 1

  local installed_app_git_url
  installed_app_git_url=$(grep APPLICATION_GIT_URL "$TARGET_APP_PATH/.metadata" 2>/dev/null | cut -f2 -d= | tr -d '"')
  local latest_app_version=$target_application_version
  target_application_installed_version=$(grep APPLICATION_VERSION "$TARGET_APP_PATH/.metadata" 2>/dev/null | cut -f2 -d= | tr -d '"')

  [ "$latest_app_version" = "$target_application_installed_version" ]
}
