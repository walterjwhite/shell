_traffic_monitor_networking() {
  ip link show "$conf_open_wifi_traffic_monitor_interface" >/dev/null 2>&1 || {
    exit_with_error "interface $conf_open_wifi_traffic_monitor_interface not found"
  }

  log_info "setting up $conf_open_wifi_traffic_monitor_interface for manual control..."


  log_info "bringing up $conf_open_wifi_traffic_monitor_interface..."
  ip link set "$conf_open_wifi_traffic_monitor_interface" up
  sleep 2

  iwctl station $conf_open_wifi_traffic_monitor_interface scan

  sleep 5

  iwctl station $conf_open_wifi_traffic_monitor_interface connect "$SDID"
}



_traffic_monitor_is_connected_to_target_ssid() {
  log_info "waiting for connection..."

  CONNECTED=0
  for i in $(seq 1 $conf_open_wifi_traffic_monitor_network_connect_timeout); do
    iwctl station $conf_open_wifi_traffic_monitor_interface show | grep -cqm1 "Connected network[\s]+$SSID" && {
      log_info "connected to $SSID"
      return
    }

    sleep 1
  done

  exit_with_error "failed to connect to $SSID"
}
