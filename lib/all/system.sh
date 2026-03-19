_system_get_id() {
  head -1 ${APP_PLATFORM_ROOT}${PLATFORM_SYSTEM_ID_PATH} 2>/dev/null
}

_system_write_id() {
  (
    printf '%s\n' $1
    printf '%s\n' $2
    printf '%s\n' $3
    git ls-remote $3 -b $1 | awk {'print$1'}

    printf 'Provision Date: %s\n' "$(date)"
  ) | _write_write ${APP_PLATFORM_ROOT}${PLATFORM_SYSTEM_ID_PATH}
}

_system_get_git_url() {
  sed -n '3p' ${APP_PLATFORM_ROOT}${PLATFORM_SYSTEM_ID_PATH}
}
