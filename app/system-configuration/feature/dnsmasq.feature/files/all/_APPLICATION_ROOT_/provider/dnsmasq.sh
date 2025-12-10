lib ./configuration.sh
lib feature:dnsmasq.sh

cfg feature:

system_configuration_dnsmasq() {
	which dnsmasq >/dev/null 2>&1 || {
		_WARN "Dnsmasq is not installed, skipping"
		return 1
	}

	cd /tmp

	_dnsmasq_backup

	rm -f $_SYSTEM_CONFIGURATION_DNSMASQ_CONF ${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dhcp ${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns

	printf '# @see: https://wiki.archlinux.org/title/Dnsmasq\n' >${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}
	printf 'conf-file=%s\n' ${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dhcp >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}
	printf 'conf-file=%s\n' ${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}
	printf 'conf-file=%s\n' ${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.local-dns >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}

	printf 'log-facility=/var/log/dnsmasq/log\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}

	_dnsmasq_dhcp
	_dnsmasq_dns
	_dnsmasq_local_dns

	unset $_SYSTEM_CONFIGURATION_DNSMASQ_CONF

	_dnsmasq_restart
}

_dnsmasq_backup() {
	[ ! -e $_SYSTEM_CONFIGURATION_DNSMASQ_CONF ] && return 1

	_WARN "Backing up $$_SYSTEM_CONFIGURATION_DNSMASQ_CONF"
	local timestamp=$(date +%Y%m%d.%H.%M.%S)
	local dnsmasq_backup_dir=$_SYSTEM_CONFIGURATION_DNSMASQ_CONF.backups/$timestamp
	mkdir -p $dnsmasq_backup_dir

	mv $_SYSTEM_CONFIGURATION_DNSMASQ_CONF $_SYSTEM_CONFIGURATION_DNSMASQ_CONF.dhcp $_SYSTEM_CONFIGURATION_DNSMASQ_CONF.dns $_SYSTEM_CONFIGURATION_DNSMASQ_CONF.local-dns $dnsmasq_backup_dir 2>/dev/null
}

_dnsmasq_local_dns() {
	_DETAIL "Writing local DNS"
	for _client_device_file in $(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -type f ! -name '.*'); do
		. $_client_device_file

		[ -z "$HOSTNAME" ] && {
			_WARN "HOSTNAME is unset: $_client_device_file"
			continue
		}
		[ -z "$IP" ] && {
			_WARN "IP is unset: $_client_device_file"
			continue
		}

		_dnsmasq_device_dns $HOSTNAME $IP

		[ -n "$DEVICE_ALIASES" ] && {
			_WARN "Device has aliases"

			printf '\n# device aliases\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.local-dns
			for DEVICE_ALIAS in $(printf '%s\n' "$DEVICE_ALIASES" | tr '|' '\n'); do
				_dnsmasq_device_dns $DEVICE_ALIAS $IP
			done
		}

		printf '\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.local-dns

		unset DEVICE_ALIASES DEVICE_ALIAS HOSTNAME IP
	done
}

_dnsmasq_device_dns() {
	printf 'address=/%s/%s\n' $1 $2 >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.local-dns

	local reverse_ip=$(printf '%s' $2 | awk -F. '{print $4"."$3"."$2"."$1}')
	printf 'ptr-record=/%s.in-addr.arpa,%s\n' $reverse_ip $1 >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.local-dns
}

_dnsmasq_dhcp() {
	printf '# default gateway\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dhcp

	_dnsmasq_write_dhcp_option '3' "$_OPTN_SYSTEM_CONFIGURATION_DNSMASQ_ROUTER" router
	_dnsmasq_write_dhcp_option '6' "$_OPTN_SYSTEM_CONFIGURATION_DNSMASQ_DNS_SERVER" 'DNS server'
	_dnsmasq_write_dhcp_option '42' "$_OPTN_SYSTEM_CONFIGURATION_DNSMASQ_NTP_SERVER" 'NTP server'
	_dnsmasq_write_dhcp_option '51' "$_OPTN_SYSTEM_CONFIGURATION_DNSMASQ_DHCP_LEASE_TIMEOUT" 'DHCP lease timeout'

	_dnsmasq_set_dhcp_range

	printf 'dhcp-leasefile=/var/db/dnsmasq/leases\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dhcp

	printf 'log-dhcp\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dhcp
	printf 'dhcp-authoritative\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dhcp
	printf 'read-ethers\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dhcp
}

_dnsmasq_set_dhcp_range() {
	printf 'dhcp-range=%s,%s,%s\n' "$_CLIENT_IP_START" "$_CLIENT_IP_END" "$_OPTN_SYSTEM_CONFIGURATION_DNSMASQ_DHCP_LEASE_TIMEOUT" >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dhcp
}

_dnsmasq_write_dhcp_option() {
	[ -z "$2" ] && return 1

	printf '# %s\n' "$3"
	printf 'dhcp-option=%s,%s\n' "$1" "$2" >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dhcp
}

_dnsmasq_dns() {

	printf 'domain=%s\n\n' "$_CONF_SYSTEM_CONFIGURATION_DNSMASQ_DOMAIN" >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns

	printf 'cache-size=%s\n' "$_CONF_SYSTEM_CONFIGURATION_DNSMASQ_CACHE_SIZE" >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns
	printf 'conf-file=%s\n' $_SYSTEM_CONFIGURATION_DNSMASQ_TRUST_ANCHOR >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns
	printf 'dnssec\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns

	printf 'domain-needed\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns
	printf 'bogus-priv\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns
	printf 'expand-hosts\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns
	printf 'no-resolv\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns

	printf 'log-queries\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns

	printf '%s\n' "$_CONF_SYSTEM_CONFIGURATION_DNSMASQ_UPSTREAM_DNS" | tr ' ' '\n' | sed -e 's/^/server=/' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns

	printf '# dns blocklist\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns

	printf 'conf-file=/usr/local/etc/walterjwhite/network/dnsmasq.block\n' >>${_SYSTEM_CONFIGURATION_DNSMASQ_CONF}.dns
	touch /usr/local/etc/walterjwhite/network/dnsmasq.block
}

_dnsmasq_restart() {
	_is_restart_services || return

	rm -f /var/log/dnsmasq/leases
	_dnsmasq_restart_do
}
