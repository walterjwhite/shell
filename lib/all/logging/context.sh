log_add_context() {
  [ -z "$1" ] && return 1

  case "$1" in
  *:*)
    exit_with_error "context string contains colon, which is not allowed"
    ;;
  esac

  if [ -z "$logging_context" ]; then
    logging_context="$1"
  else
    logging_context="${logging_context}:$1"
  fi
}

log_remove_context() {
  [ -z "$logging_context" ] && return 1

  case $logging_context in
  *:*)
    logging_context=$(printf '%s' "$logging_context" | sed -e 's/\:[a-zA-Z0-9/@\. _-]*$//')
    ;;
  *)
    unset logging_context
    ;;
  esac
}
