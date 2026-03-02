lib git/data.app.sh

cfg git

_is_unsupported_platform() {
  [ -z "$provider_path" ]
}

_is_feature_disabled() {
  _environment_variable_is_set ${provider_function_name}_disabled
}

_configuration_action() {
  _is_unsupported_platform && {
    log_debug "unsupported on $APP_PLATFORM_PLATFORM"
    return 1
  }

  _is_feature_disabled && {
    log_debug "disabled"
    return 2
  }

  if [ -n "$provider_no_root_user" ] && [ "$USER" = "root" ]; then
    log_debug "plugin does not support root user"
    return 3
  fi

  configuration_$action || return 4

  log_info "$action"

  exec_call _configuration_${provider_function_name}_${action}_pre

  exec_call _configuration_${provider_function_name}_${action} || configuration_${action}_default
  exec_call _configuration_${provider_function_name}_${action}_post
  exec_call configuration_${action}_post
}
