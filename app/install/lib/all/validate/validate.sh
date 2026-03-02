_validate_app_install() {
  _validate_app_checkout_version || exit_defer _validate_app_reset_registry

  while read _app_file; do
    validate_file_checksum=$(sha256 -q $_app_file)

  done <$APP_PLATFORM_LIBRARY_PATH/$target_application_name/.files

  unset _app_file
}

_validate_app_checkout_version() {
  cd $REGISTRY_PATH

  validate_target_application_version=$(grep APPLICATION_VERSION $APP_PLATFORM_LIBRARY_PATH/$target_application_name/.metadata 2>/dev/null | cut -f2 -d=)

  git checkout $validate_target_application_version

  [ $(git rev-parse HEAD) = $validate_target_application_version ]
}

_validate_app_reset_registry() {
  cd $REGISTRY_PATH
  git reset --hard HEAD
}
