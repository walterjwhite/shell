_domain_blocks_strip() {
	$_CONF_GNU_GREP -Pv "(^#.*$|^$|^localhost$)" | sed -e "s/\r//"
}

_domain_blocks_filter() {
	cat
}

_domain_blocks_install() {
	_NAME=$(basename $0 | sed -e 's/\.sh//' -e 's/\.run//')
	_INFO "Updating $_NAME rules"

	local target_file=$_CONF_DOMAIN_BLOCKS_BLOCKLIST/$_NAME
	_sudo mkdir -p $(dirname $target_file)

	curl --connect-timeout $_CONF_DOMAIN_BLOCKS_CURL_CONNECT_TIMEOUT -s $1 | _domain_blocks_strip | _domain_blocks_filter | sort -u | _sudo tee $target_file >/dev/null
}

_domain_blocks_aggregate() {
	_sudo mkdir -p $1

	find $1 -type f ! -name '.aggregate' -exec cat {} \; 2>/dev/null |
		$_CONF_GNU_GREP -Pv "^(#|$)" |
		sort -u | _sudo tee $1/.aggregate >/dev/null 2>&1
}
