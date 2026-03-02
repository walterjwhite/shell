for _REQUIRED_APP_CONF_ITEM in $_REQUIRED_APP_CONF; do
  _environment_variable_is_set $_REQUIRED_APP_CONF_ITEM || {
    log_warn "required configuration unset: $_REQUIRED_APP_CONF_ITEM"
    local _MISSING_REQUIRED_CONF=1
  }
done

if [ -n "$_MISSING_REQUIRED_CONF" ]; then
  exit_with_error "required configuration is missing, please refer to above error(s)"
fi
