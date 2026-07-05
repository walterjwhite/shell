uninstall_app() {
  validation_require "$target_application_name" target_application_name
  validation_require "$TARGET_APP_PATH" TARGET_APP_PATH

  [ ! -e "$TARGET_APP_PATH" ] && return 1
  [ ! -e "$TARGET_APP_PATH/.metadata" ] && return 1

  rm -rf "$TARGET_APP_PATH/.metadata"

  uninstall_type

  [ -n "$clean" ] && rm -rf "$TARGET_APP_PATH"

  log_info "uninstalled $target_application_name"
}

uninstall_type() {
  [ ! -e "$TARGET_APP_PATH/type" ] && return 1

  local _setup_type_file
  find "$TARGET_APP_PATH/type" -type f |
    while IFS= read -r _setup_type_file; do
      local setup_type_name
      setup_type_name=$(basename "$_setup_type_file")
      local setup_type_function_name
      setup_type_function_name=$(printf '%s' "$setup_type_name" | tr '[:upper:]' '[:lower:]')

      exec_call "${setup_type_function_name}_uninstall" "$_setup_type_file"
    done

  rm -rf "$TARGET_APP_PATH/type"
}
