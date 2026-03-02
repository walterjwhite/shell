lib ./configuration.sh

system_configuration_ethers() {
  rm -f /etc/ethers /etc/ethers.arp

  for _client_device_file in $_sorted_devices; do
    . $_client_device_file
    _configuration_mac

    if [ "$_mac" = "00:00:00:00:00:00" ]; then
      log_warn "skipping device with zero MAC: $(basename $(dirname $_client_device_file))"
    else
      printf '%s %s\n' "$_mac" "$_ip" >>/etc/ethers.unsorted

      printf '%s %s\n' "$_ip" "$_mac" >>/etc/ethers.arp.unsorted
    fi

    unset _ip _fqdn _hostname _DOMAIN
  done

  sort -V -k2 /etc/ethers.unsorted | awk '{ printf "%-15s %s\n", $1, $2 }' >/etc/ethers
  sort -V -k1 /etc/ethers.arp.unsorted | awk '{ printf "%-15s %s\n", $1, $2 }' >/etc/ethers.arp

  rm -f /etc/ethers.unsorted /etc/ethers.arp.unsorted

  _is_restart_services || return

  arp -f /etc/ethers.arp
}
