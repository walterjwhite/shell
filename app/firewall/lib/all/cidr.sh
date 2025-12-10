_firewall_country_block_add_declared() {
	$_CONF_GNU_GREP -rPo '(CIDR|IP)=.*$' /usr/local/etc/walterjwhite/firewall/macro |
		cut -f2 -d'=' |
		tr -d '"' | tr -d '}' | tr -d '{' | tr ' ' '\n' |
		sort -u >>$_COUNTRY_ALLOWLIST
}
