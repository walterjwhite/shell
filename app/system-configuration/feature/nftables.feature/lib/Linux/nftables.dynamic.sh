_nftables_update_sets() {
	_nftables_build_sets

	local nftables_dynamic_schedule_file=$(_mktemp)

	printf '# nftables - dynamic schedule\n' >>$nftables_dynamic_schedule_file
	printf '* * * * * firewall-update-tables > /dev/null 2>&1\n' >>$nftables_dynamic_schedule_file

	_crontab_append root $nftables_dynamic_schedule_file
	rm -f $nftables_dynamic_schedule_file
}

_nftables_build_sets() {
	rm -rf $FIREWALL/sets.dynamic.nft
	[ ! -e $FIREWALL/dynamic ] && return

	local set set_name set_cname_size set_size
	for set in $(find $FIREWALL/dynamic -type f ! -name '*.data'); do
		set_name=$(basename $set)
		set_cname_size=$(wc -l <$set)
		set_size=$(($set_cname_size * 128))

		printf 'set dynamic_%s {\n' $set_name >>$FIREWALL/sets.dynamic.nft
		printf '  type ipv4_addr\n' >>$FIREWALL/sets.dynamic.nft
		printf '  size %s\n' $set_size >>$FIREWALL/sets.dynamic.nft
		printf '  flags interval\n' >>$FIREWALL/sets.dynamic.nft
		printf '  auto-merge\n' >>$FIREWALL/sets.dynamic.nft
		printf '}\n' $set_size >>$FIREWALL/sets.dynamic.nft
		printf '\n' $set_name >>$FIREWALL/sets.dynamic.nft
	done
}

_nftables_clear() {
	local existing_crontab=$(_mktemp)

	_crontab_get root $existing_crontab
	$_CONF_GNU_SED -i '/^$/d' $existing_crontab

	$_CONF_GNU_SED -i '/firewall-update-/d' $existing_crontab
	$_CONF_GNU_SED -i '/nft /d' $existing_crontab
	$_CONF_GNU_SED -i '/# nftables - dynamic schedule/d' $existing_crontab
	$_CONF_GNU_SED -i '/# nftables - set schedule/d' $existing_crontab
	$_CONF_GNU_SED -i '/conntrack/d' $existing_crontab

	_crontab_write root "$existing_crontab"

	rm -f $existing_crontab
}

_nftables_build_static_sets() {
	[ ! -e $FIREWALL/set ] && return

	rm -rf $FIREWALL/sets.static.nft
	find $FIREWALL/set -type f -exec cat {} + >>$FIREWALL/sets.static.nft
}
