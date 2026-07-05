_firewall_flush_table() {
  local _table_name=$1

  validation_require "$_table_name" "table name is required"

  sudo_run pfctl -t "$_table_name" -T flush
}

_firewall_update_table() {
  local _table_name=$1
  shift

  validation_require "$_table_name" "table name is required"
  [ $# -eq 0 ] && exit_with_error "iP address(es) to add is required"

  sudo_run pfctl -t "$_table_name" -T add "$*"
}

_firewall_update_table_from_file() {
  local _table_name=$1
  local _file=$2

  sudo_run pfctl -t "$_table_name" -T replace -f "$_file"
}

_firewall_check() {
  sudo_run service pf check
}

_firewall_restart() {
  sudo_run service pf restart
}
