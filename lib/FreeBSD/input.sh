_input_alert() {
  command -v notify-send >/dev/null 2>&1 || return 1

  [ "$XAUTHORITY" ] && notify-send -e "$*"
}
