_beep_beep() {
  [ -z "$interactive" ] && {
    log_warn "non-interactive"
    return 2
  }

  [ -n "$SSH_CLIENT" ] && {
    log_warn "remote connection detected, not beeping"
    return 1
  }

  say $optn_install_apple_say_options $conf_install_apple_beep_message
}

sudo_precmd() {
  [ -z "$interactive" ] && {
    log_warn "non-interactive"
    return 2
  }
  
  [ -n "$SSH_CLIENT" ] && {
    log_warn "remote connection detected, not beeping"
    return 1
  }

  say $optn_install_apple_say_options $conf_install_apple_sudo_precmd_message
}
