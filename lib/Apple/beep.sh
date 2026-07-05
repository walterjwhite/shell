_beep_beep() {
  [ -n "$NON_INTERACTIVE" ] && {
    log_warn "non-interactive"
    return 2
  }

  [ -n "$SSH_CLIENT" ] && {
    log_warn "remote connection detected, not beeping"
    return 1
  }

  say $say_options $conf_install_apple_beep_message
}

sudo_precmd() {
  [ -n "$NON_INTERACTIVE" ] && {
    log_warn "non-interactive"
    return 2
  }

  [ -n "$SSH_CLIENT" ] && {
    log_warn "remote connection detected, not beeping"
    return 1
  }

  say $say_options $conf_install_apple_sudo_precmd_message
}
