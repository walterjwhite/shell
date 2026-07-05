lib io/write.sh

_cachyos_switch_to_systemd_networking() {
  sudo_run systemctl disable --now NetworkManager
  sudo_run rm -f /etc/resolv.conf
  sudo_run ln -s /run/systemd/resolve/stub-resolv.conf /etc/resolv.conf
  sudo_run $GNU_SED -i 's/#DNSSEC=no/DNSSEC=no/' /etc/systemd/resolved.conf

  _cachyos_write_network_cfg

  sudo_run systemctl enable --now systemd-networkd systemd-resolved
}

_cachyos_write_network_cfg() {
  interface=$(ip link show | grep ' UP ' | awk {'print$2'} | sed -e 's/://')

  {
    printf '[Match]\n'
    printf 'Name=%s\n' $interface

    printf '[Network]\n'
    printf 'DHCP=yes\n'
    printf 'IgnoreCarrierLoss=3s\n'
    printf 'DefaultRoute=yes\n\n'

    printf '[DHCPv4]\n'
    printf 'UseNTP=Yes\n'
    printf 'UseDNS=Yes\n'
    printf '# Tells networkd to accept the search domain handed out by your DHCP server\n'
    printf 'UseDomains=Yes\n'
    printf 'RouteMetric=100\n'
  } | _write_write /etc/systemd/network/20-$interface.network
}
