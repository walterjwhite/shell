configuration_restore() {
  exec_call _configuration_${provider_function_name}_clear || configuration_clear_default

  [ ! -e $provider_data_path ] && {
    log_debug "no configuration found"
    return 255
  }

  [ -n "$provider_path_is_dir" ] && {
    [ -z "$provider_path_is_skip_prepare" ] && mkdir -p "$provider_path"

    return 0
  }

  provider_parent_dir=$(dirname "$provider_path")

  mkdir -p "$provider_parent_dir"
  provider_path="$provider_parent_dir"
}

configuration_restore_default() {
  [ ! -e "$provider_data_path" ] && return

  tar -cp $tar_args -C "$provider_data_path" . | tar -xp $tar_args -C "$provider_path"
}

configuration_restore_sync() {
  :
}
