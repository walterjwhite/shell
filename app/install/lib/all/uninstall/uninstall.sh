uninstall_app() {
  validation_require "$target_application_name" target_application_name
  validation_require "$APP_PATH" APP_PLATFORM_PATH

  [ ! -e "$APP_PLATFORM_PATH/apps/$target_application_name" ] && return 1
  [ ! -e "$APP_PLATFORM_PATH/apps/$target_application_name/.metadata" ] && return 1

  rm -rf "$APP_PLATFORM_PATH/apps/$target_application_name/.metadata" \
    "$APP_PLATFORM_PATH/apps/$target_application_name/help"

  uninstall_type

  [ -n "$clean" ] && rm -rf "$APP_PLATFORM_PATH/apps/$target_application_name"

  log_info "uninstalled $target_application_name"
}

uninstall_type() {
  [ ! -e "$APP_PLATFORM_PATH/apps/$target_application_name/type" ] && return 1

  local _setup_type_file
  find "$APP_PLATFORM_PATH/apps/$target_application_name/type" -type f |
    while IFS= read -r _setup_type_file; do
      local setup_type_name
      setup_type_name=$(basename "$_setup_type_file")
      local setup_type_function_name
      setup_type_function_name=$(printf '%s' "$setup_type_name" | tr '[:upper:]' '[:lower:]')

      exec_call "_${setup_type_function_name}_uninstall" "$_setup_type_file"
    done

  rm -rf "$APP_PLATFORM_PATH/apps/$target_application_name/type"
}
