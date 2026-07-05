lib io/file.sh
lib net/public-ip.sh

_vpn_client_ip() {
  _public_ip_fetch || exit_with_error "unable to determine public IP"

  _self_client_ip=$public_ip_address
  unset public_ip_address

  validation_require "$_self_client_ip" _self_client_ip
}

_vpn_server_ip() {
  [ -n "$conf_vpn_remote_server_ip" ] && {
    export conf_vpn_remote_server_ip=$conf_vpn_remote_server_ip
  }
}

_vpn_firewall_cleanup() {
  log_warn "cleaning up vpn"

  [ -n "$vpn_provider_pids" ] && {
    timeout -k 2s 5s kill -15 $vpn_provider_pids
  }

  timeout -k 2s 5s publish-cmd vpn_stop || exit_with_error "failed to publish vpn stop cmd"
}

_vpn_firewall_update() {
  log_warn "updating firewall to allow vpn client"

  timeout -k 2s 5s publish-cmd vpn_start $_self_client_ip || exit_with_error "failed to publish vpn start cmd"
}

_vpn_firewall_wait_conf() {
  log_info "waiting 5s for remote server to implement changes"
  sleep 5
}

_vpn_provider() {
  for vpn_provider in $conf_vpn_provider; do
    case $vpn_provider in
    wireguard | wstunnel) ;;
    *)
      exit_with_error "unsupported vpn_provider:$vpn_provider"
      ;;
    esac

    $APP_PATH/bin/${vpn_provider}-client "$@" &
    vpn_provider_pids="$vpn_provider_pids $!"
  done
}
