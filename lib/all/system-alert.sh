_system_alert_alert() {
  [ -z "$system" ] && system=$(head -1 /usr/local/etc/walterjwhite/system)

  local _message
  _message=$(printf '%s\n%s\n' "$2")
  _alert_alert "$system: $1" "$_message"
}
