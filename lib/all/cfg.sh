_cfg_validate_required() {
  [ -n "$REQUIRED_APP_CONF" ] && {
    for required_app_conf_element in $REQUIRED_APP_CONF; do
      _environment_variable_is_set $required_app_conf_element || {
        log_warn "required configuration unset: $required_app_conf_element"
        missing_required_conf=1
      }
    done

    if [ -n "$missing_required_conf" ]; then
      exit_with_error "required configuration is missing, please refer to above error(s)"
    fi
  }
}
