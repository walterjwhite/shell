_settings_init() {
  log_info "using root directory: $APP_PLATFORM_ROOT"

  _include_optional $APPLICATION_METADATA_PATH

  if [ "$APP_PLATFORM_ROOT" != "/" ]; then
    log_warn "using alternate root: $APP_PLATFORM_ROOT"
    unset $(set | tr '\0' '\n' | $GNU_GREP -P '^bootstrap_[a-z0-9_]+=' | sed -e 's/=.*$//' | tr '\n' ' ')
  fi
}

_settings_application() {
  target_application_install_date=$(date +"%a %b %d %H:%M:%S %Y %z")

  mkdir -p $APP_DATA_PATH/install $DATA_PATH

  _include_optional $target_application_name
}

_settings_application_defaults() {
  local default_file
  for default_file in $(find $1/cfg -type f 2>/dev/null); do
    [ -f $default_file ] && . $default_file
  done
}
