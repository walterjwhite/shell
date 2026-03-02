uninstall_app() {
  validation_require "$target_application_name" target_application_name
  validation_require "$APP_LIBRARY_PATH" APP_LIBRARY_PATH

  [ ! -e $APP_PLATFORM_LIBRARY_PATH/$target_application_name ] && return 1
  [ ! -e $APP_PLATFORM_LIBRARY_PATH/$target_application_name/.metadata ] && return 1

  rm -rf $APP_PLATFORM_LIBRARY_PATH/$target_application_name/.metadata \
    $APP_PLATFORM_LIBRARY_PATH/$target_application_name/help

  uninstall_type

  [ -n "$clean" ] && rm -rf $APP_PLATFORM_LIBRARY_PATH/$target_application_name

  log_info "uninstalled $target_application_name"
}

uninstall_type() {
  [ ! -e $APP_PLATFORM_LIBRARY_PATH/$target_application_name/type ] && return 1

  for _SETUP_TYPE_FILE in $(find $APP_PLATFORM_LIBRARY_PATH/$target_application_name/type -type f -name '.*'); do
    local setup_type_name=$(basename $_SETUP_TYPE_FILE | sed -e 's/^.//')
    local setup_type_function_name=$(printf "$setup_type_name" | tr '[:upper:]' '[:lower:]')

    exec_call _${setup_type_function_name}_uninstall $_SETUP_TYPE_FILE
  done

  rm -rf $APP_PLATFORM_LIBRARY_PATH/$target_application_name/type
}
