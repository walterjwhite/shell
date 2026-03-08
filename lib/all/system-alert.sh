lib system.sh

_system_alert() {
  [ -z "$system" ] && {
    system_get_id
    system=$system_id
  }

  local _message
  _message=$(printf '%s\n%s\n' "$2")
  _alert_alert "$system: $1" "$_message"
}
