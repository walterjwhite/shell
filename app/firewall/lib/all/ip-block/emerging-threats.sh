lib io/file.sh

_FIREWALL_IP_BLOCK_ET() {
	FIREWALL_PROVIDER_TEMP_FILE=$(_mktemp)

	local ip_block_url
	for ip_block_url in $_CONF_FIREWALL_IP_BLOCK_ET; do
		_firewall_ip_block_download $FIREWALL_PROVIDER_TEMP_FILE $ip_block_url || _WARN "Downloading $ip_block_url returned $?"
	done
}

_firewall_ip_block_download() {
	curl -sL "${2}" | $_CONF_GNU_GREP -Pv '^(#|$)' >>$1
}
