_beep_beep() {
  [ "$EUID" -eq 0 ] && return 1

  beep $1 &
}

sudo_precmd() {
  _beep_beep "$conf_log_sudo_beep_tone"
}
