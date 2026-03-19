lib system.sh

_system_alert() {
  [ -z "$system_id" ] && {
    system_id=$(_system_get_id)
  }

  local _message
  _message=$(printf '%s\n%s\n' "$2")
  _alert_alert "$system_id: $1" "$_message"
}
