_beep_beep() {
  [ -n "$SSH_CLIENT" ] && {
    log_warn "remote connection detected, not beeping"
    return 1
  }

  say $optn_install_apple_say_options $conf_install_apple_beep_message
}

sudo_precmd() {
  [ -n "$SSH_CLIENT" ] && {
    log_warn "remote connection detected, not beeping"
    return 1
  }

  say $optn_install_apple_say_options $conf_install_apple_sudo_precmd_message
}
