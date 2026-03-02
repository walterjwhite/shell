proxy_start() {
  $conf_remote_service_cmd $conf_remote_proxy_service_name $conf_remote_service_start_action
}

proxy_stop() {
  $conf_remote_service_cmd $conf_remote_proxy_service_name $conf_remote_service_stop_action
}
