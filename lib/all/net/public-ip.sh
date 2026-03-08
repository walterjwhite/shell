public_ip_address=""

_public_ip_fetch() {
  local _host
  for _host in ifconfig.me ipinfo.io/ip icanhazip.com; do
    _public_ip_fetch_address $_host && {
      log_info "public IP: $public_ip_address"
      return
    }
  done

  log_warn "unable to determine public IP"
  return 1
}

_public_ip_fetch_address() {
  local _host=$1
  public_ip_address=$(curl -s $_host | $GNU_GREP -Po '[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}\.[\d]{1,3}')
  if [ -z "$public_ip_address" ]; then
    unset public_ip_address
    return 1
  fi

  return 0
}
