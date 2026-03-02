_env_init() {
  [ ! -e .run/.env ] && return 1

  log_info "loading env"

  local env_line
  for env_line in $($GNU_GREP -Pv '(^$|^#)' .run/.env); do
    log_debug "processing env: $env_line"
    export "$env_line"
  done
}

_env_display() {
  local var_names
  var_names=$($GNU_GREP -Pvh '(^$|^#)' .run/.env .run/.secrets | sed -e 's/=.*$//' | tr '\n' '|')
  env | $GNU_GREP -Po "^($var_names)=.*"
}
