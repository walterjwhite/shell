configuration_restore() {
  exec_call _configuration_${provider_function_name}_clear || configuration_clear_default

  [ ! -e $APP_DATA_PATH/$provider_name ] && {
    log_debug "no configuration found"
    return 255
  }

  if [ -n "$dry_run" ]; then
    if [ -z "$CONFIG_DRY_RUN_TEMP_DIR" ]; then
      export CONFIG_DRY_RUN_TEMP_DIR=$(mktemp -d -t config-restore-XXXXXX)
      log_info "dry run: restoring all configurations to temporary directory: $CONFIG_DRY_RUN_TEMP_DIR"
    fi
    provider_path="$CONFIG_DRY_RUN_TEMP_DIR/$provider_name"
    provider_path_is_dir=1
    provider_path_is_skip_prepare=1
  fi

  [ -n "$provider_path_is_dir" ] && {
    [ -z "$provider_path_is_skip_prepare" ] && mkdir -p "$provider_path"

    return 0
  }

  provider_parent_dir=$(dirname "$provider_path")

  mkdir -p $provider_parent_dir
  provider_path="$provider_parent_dir"
}

configuration_restore_default() {
  [ ! -e $APP_DATA_PATH/$provider_name ] && return

  tar -cp $tar_args -C $APP_DATA_PATH/$provider_name . | tar -xp $tar_args -C "$provider_path"
}

configuration_restore_sync() {
  :
}
