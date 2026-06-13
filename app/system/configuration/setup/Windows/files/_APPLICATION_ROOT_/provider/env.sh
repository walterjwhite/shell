provider_path=${alt_path}$HOME/.config
provider_no_root_user=1

_configuration_env_backup() {
  rm -f "$APP_DATA_PATH/$provider_name"

  local env_var_name env_var_value
  for env_var_name in $(_get_user_env_vars); do
    env_var_value=$(_get_user_env_var_value $env_var_name)

    printf '%s=%s' "$env_var_name" "$env_var_value" >>"$APP_DATA_PATH/$provider_name"
  done
}

_get_user_env_vars() {
  powershell '[System.Environment]::GetEnvironmentVariables("User")' |
    sed 1,3d |
    awk {'print$1'} |
    sort -u
}

_get_user_env_var_value() {
  powershell '[System.Environment]::GetEnvironmentVariables("User")' |
    grep "^${1} " |
    awk {'print$2'}
}

_configuration_env_restore() {
  [ ! -e "$APP_DATA_PATH/$provider_name" ] && return

  local env_line env_var_name env_var_value
  while read -r env_line; do
    env_var_name=$(printf '%s' "$env_line" | cut -f1 -d=)
    env_var_value=$(printf '%s' "$env_line" | cut -f2 -d=)

    setx "$env_var_name" "$env_var_value"
  done <"$APP_DATA_PATH/$provider_name"
}
