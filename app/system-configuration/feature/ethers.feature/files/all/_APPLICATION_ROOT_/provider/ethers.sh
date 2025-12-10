lib ./configuration.sh

system_configuration_ethers() {
	rm -f /etc/ethers /etc/ethers.arp

	for _client_device_file in $(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -type f ! -name '.*'); do
		. $_client_device_file
		_mac

		printf '%s %s\n' "$_MAC" "$IP" >>/etc/ethers.unsorted

		printf '%s %s\n' "$IP" "$_MAC" >>/etc/ethers.arp.unsorted

		unset IP FQDN HOSTNAME DOMAIN
	done

	sort -V -k2 /etc/ethers.unsorted | awk '{ printf "%-15s %s\n", $1, $2 }' >/etc/ethers
	sort -V -k2 /etc/ethers.arp.unsorted | awk '{ printf "%-15s %s\n", $1, $2 }' >/etc/ethers.arp

	rm -f /etc/ethers.unsorted /etc/ethers.arp.unsorted

	_is_restart_services || return

	arp -f /etc/ethers.arp
}
