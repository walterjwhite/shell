_validate_app_install() {
  _validate_app_checkout_version || exit_defer _validate_app_reset_registry

  while read _app_file; do
    validate_file_checksum=$(sha256 -q $_app_file)

  done <$APP_PLATFORM_PATH/apps/$target_application_name/.files

  unset _app_file
}

_validate_app_checkout_version() {
  cd $registry_path

  validate_target_application_version=$(grep APPLICATION_VERSION $APP_PLATFORM_PATH/apps/$target_application_name/.metadata 2>/dev/null | cut -f2 -d=)

  git checkout $validate_target_application_version

  [ $(git rev-parse HEAD) = $validate_target_application_version ]
}

_validate_app_reset_registry() {
  cd $registry_path
  git reset --hard HEAD
}
