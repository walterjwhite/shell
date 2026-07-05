_validate_app_install() {
  _validate_app_checkout_version || exit_defer _validate_app_reset_registry

  [ ! -d "$TARGET_APP_PATH/type" ] && return 0

  find "$TARGET_APP_PATH/type" -type f | while IFS= read -r _type_file; do
    while IFS= read -r _app_file; do
      case "$_app_file" in
      */) [ -d "$_app_file" ] || log_warn "tracked directory missing: $_app_file" ;;
      *) [ -f "$_app_file" ] || log_warn "tracked file missing: $_app_file" ;;
      esac
    done <"$_type_file"
  done

  unset _app_file _type_file
}

_validate_app_checkout_version() {
  cd "$registry_path"

  validate_target_application_version=$(grep APPLICATION_VERSION "$TARGET_APP_PATH/.metadata" 2>/dev/null | cut -f2 -d=)

  git checkout "$validate_target_application_version"

  [ "$(git rev-parse HEAD)" = "$validate_target_application_version" ]
}

_validate_app_reset_registry() {
  cd "$registry_path"
  git reset --hard HEAD
}
