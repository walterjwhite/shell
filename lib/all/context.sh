context_id_is_valid() {
  printf '%s' "$1" | $GNU_GREP -Pq '^[a-zA-Z0-9_+-]+$' || exit_with_error "context ID *MUST* only contain alphanumeric characters and +-: '^[a-zA-Z0-9_+-]+$' | ($1)"
}

_context_application_version() {
  grep APPLICATION_VERSION $APP_LIBRARY_PATH/.metadata 2>/dev/null | cut -f2 -d= | tr -d '"'
}
