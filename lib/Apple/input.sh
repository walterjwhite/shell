_input_interactive_alert() {
  [ -n "$SSH_CLIENT" ] && {
    log_warn "remote connection detected, not beeping"
    log_warn "$*"
    return 1
  }

  say "$*"
}
