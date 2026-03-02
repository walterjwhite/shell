_wait_network() {
  ping -qo -i $conf_system_maintenance_network_backoff_time -c $conf_system_maintenance_network_retries $conf_system_maintenance_network_target >/dev/null 2>&1 && {
    log_detail "network is up"
    return
  }

  exit_with_error "unable to get network connection"
}
