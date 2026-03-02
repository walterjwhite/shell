_beep_beep() {
  [ -e /dev/speaker ] || return

  printf '%s' "$@" >/dev/speaker 2>/dev/null &
}

sudo_precmd() {
  _beep_beep $conf_log_sudo_beep_tone
}
