lib system.sh

_system_alert() {
  [ -z "$system_id" ] && {
    system_id=$(_system_get_id)
  }

  _alert_alert "$system_id: $1" "$2"
}
