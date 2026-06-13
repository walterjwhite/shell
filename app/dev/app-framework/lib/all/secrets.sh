_run_init_secrets() {
  [ ! -e .run/.secrets ] && return 1

  log_info "loading secrets"
  secrets unlock 2>/dev/null

  local secret_line secret_env_key secret_key
  for secret_line in $($GNU_GREP -Pv '(^$|^#)' .run/.secrets); do
    secret_env_key="${secret_line%%=*}"
    secret_key="${secret_line#*=}"

    log_debug "processing secret: $secret_env_key"
    export "$secret_env_key"="$(secrets -out=stdout get "$secret_key")"
  done
}
