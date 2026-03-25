log_add_context() {
  [ -z "$1" ] && return 1

  local context_to_add="$1"

  case "$context_to_add" in
  *:*)
    log_debug "replacing : with |"
    context_to_add=$(printf '%s' "$context_to_add" | tr ':' '|')
    ;;
  esac

  if [ -z "$logging_context" ]; then
    logging_context="$context_to_add"
  else
    logging_context="${logging_context}:$context_to_add"
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
