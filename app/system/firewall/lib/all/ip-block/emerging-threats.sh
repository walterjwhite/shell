lib io/file.sh

_firewall_ip_block_et() {
  local firewall_temp_file=$(_mktemp_mktemp)

  local ip_block_url
  for ip_block_url in $conf_firewall_ip_block_et; do
    _firewall_ip_block_download $firewall_temp_file $ip_block_url || log_warn "downloading $ip_block_url returned $?"
  done

  _firewall_update_ip_block_update_firewall $firewall_temp_file
}

_firewall_ip_block_download() {
  curl -sL "${2}" | $GNU_GREP -Pv '^(#|$)' >>$1
}
