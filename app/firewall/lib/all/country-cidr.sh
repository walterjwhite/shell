lib net/firewall.sh

_firewall_country_block_download() {
	local tmp_download=$(_mktemp)

	curl -sL "http://www.ipdeny.com/ipblocks/data/aggregated/${1}-aggregated.zone" -o $tmp_download
	cat $tmp_download >>$_COUNTRY_ALLOWLIST
	rm -f $tmp_download
}

_firewall_country_block_download_all() {
	local country
	for country in $(printf '%s\n' "$_OPTN_FIREWALL_ALLOW_COUNTRIES"); do
		_firewall_country_block_download $country
	done
}

_firewall_country_block_refresh() {
	_firewall_update_table_from_file $_COUNTRY_ALLOWLIST
}
