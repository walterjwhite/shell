_app_setup_project() {
  target_application_version_requested=""
  case $target_application_name in
  *@*)
    target_application_version_requested=${target_application_name#*@}
    target_application_name=${_TARGET_APPLICATION_NAME%@*}
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

  _is_latest $target_application_name && {
    [ -z "$force" ] && {
      log_warn "latest version of app is already installed: $target_application_name [$target_application_version]"
      return 1
    }
  }

  _app_is_app

  [ ! -e $APP_PLATFORM_PLATFORM ] && exit_with_error "no artifacts exist for $APP_PLATFORM_PLATFORM"

  _settings_application
  _settings_application_defaults $APP_PLATFORM_PLATFORM


  [ $_OPTN_INSTALL_BYPASS_UNINSTALL ] || _INSTALL=1 uninstall_app
  _install_prepare_target

  _metadata_write_app

  _setup_main $REGISTRY_PATH/$target_application_name/$APP_PLATFORM_PLATFORM/setup
  _setup_main $REGISTRY_PATH/$target_application_name/$APP_PLATFORM_PLATFORM/post-setup

  log_info "$target_application_name - Completed installation"
}
