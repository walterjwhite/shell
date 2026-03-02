lib net/firewall.sh

vpn_start() {
  _firewall_update_table $conf_remote_vpn_client_table_name $1

  vpn_already_running || $conf_remote_service_start_cmd
}

vpn_stop() {
  _firewall_flush_table $conf_remote_vpn_client_table_name

  $conf_remote_service_stop_cmd
}

vpn_already_running() {
  ifconfig $conf_remote_interface_name >/dev/null 2>&1
}
