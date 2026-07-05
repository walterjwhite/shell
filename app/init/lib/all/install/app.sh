_app_setup_project() {
  target_application_version_requested=""
  case $target_application_name in
  *@*)
    target_application_version_requested=${target_application_name#*@}
    target_application_name=${target_application_name%@*}
    [ -n "$target_application_version_requested" ] && force=1
    ;;
  esac

  case $target_application_name in
  *.zip)
    exit_with_error "expecting $target_application_name:<APPLICATION_NAME>"
    ;;
  *.zip:*)
    _git_zip_install_app_registry
    ;;
  *)
    _git_clone
    ;;
  esac

  _git_has_updates

  _app_is_app || exit_with_error "$target_application_name is not a valid app (no .app file in registry)"
  [ ! -e "$target_platform" ] && exit_with_error "no artifacts exist for $target_platform"

  _settings_application
  _settings_application_defaults "$target_platform"

  _is_latest "$target_application_name" && {
    [ -z "$force" ] && {
      log_warn "latest version of app is already installed: $target_application_name [$target_application_version]"
      return 1
    }
  }

  uninstall_app
  _install_prepare_target

  _metadata_write_app

  _setup_main "$registry_path/$target_application_name/$target_platform/setup"
  _setup_main "$registry_path/$target_application_name/$target_platform/post-setup"

  log_info "$target_application_name - Completed installation"
}
