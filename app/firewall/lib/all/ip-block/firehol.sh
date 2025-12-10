_FIREWALL_IP_BLOCK_FIREHOL() {
	local tmp_dir=$(_MKTEMP_OPTIONS=d _mktemp)
	FIREWALL_PROVIDER_TEMP_FILE=$(_mktemp)

	git clone --depth 1 https://github.com/firehol/blocklist-ipsets.git $tmp_dir >/dev/null 2>&1 || {
		_WARN "Unable to clone https://github.com/firehol/blocklist-ipsets.git"
		return 1
	}

	find $tmp_dir -mindepth 1 -maxdepth 1 -type f -name '*.ipset' \
		-exec $_CONF_GNU_GREP -Pvh '(^$|^#)' {} + | sort -u >>$FIREWALL_PROVIDER_TEMP_FILE

	rm -rf $tmp_dir
}
