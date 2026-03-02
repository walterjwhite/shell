lib io/file.sh
lib net/public-ip.sh

_vpn_client_ip() {
  _public_ip_fetch || exit_with_error "unable to determine public IP"

  _self_client_ip=$public_ip_address
  unset public_ip_address

  validation_require "$_self_client_ip" SELF_CLIENT_IP
}

_vpn_firewall_cleanup() {
  [ -n "$_VPN_PID" ] && kill -9 $_VPN_PID
  [ -n "$_WEB_BROWSER_PID" ] && kill -9 $_WEB_BROWSER_PID

  log_warn "cleaning up vpn"
  publish-cmd -func _VPN_STOP
}

_vpn_firewall_update() {
  log_warn "updating firewall to allow vpn client"

  publish-cmd -func _VPN_START -args "$_self_client_ip"
}

_vpn_firewall_wait_conf() {
  log_info "waiting 5s for remote server to implement changes"
  sleep 5
}
