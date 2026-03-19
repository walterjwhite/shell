lib io/file.sh
lib net/public-ip.sh

_vpn_client_ip() {
  _public_ip_fetch || exit_with_error "unable to determine public IP"

  _self_client_ip=$public_ip_address
  unset public_ip_address

  validation_require "$_self_client_ip" _self_client_ip
}

_vpn_server_ip() {
  [ -n "$vpn_remote_server_ip" ] && {
    export vpn_remote_server_ip=$vpn_remote_server_ip
  }
}

_vpn_firewall_cleanup() {
  [ -n "$_VPN_PID" ] && kill -9 $_VPN_PID
  [ -n "$_WEB_BROWSER_PID" ] && kill -9 $_WEB_BROWSER_PID

  log_warn "cleaning up vpn"

  publish-cmd vpn_stop
}

_vpn_firewall_update() {
  log_warn "updating firewall to allow vpn client"

  publish-cmd vpn_start $_self_client_ip
}

_vpn_firewall_wait_conf() {
  log_info "waiting 5s for remote server to implement changes"
  sleep 5
}

_vpn_provider() {
  case $vpn_provider in
  wireguard) ;;
  *)
    exit_with_error "unsupported vpn_provider:$vpn_provider"
    ;;
  esac

  $APP_LIBRARY_PATH/bin/${vpn_provider}-client "$@"
}
