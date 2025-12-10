_nftables_build_variables() {
	rm -rf $FIREWALL/group $FIREWALL/groups.nft $FIREWALL/variables.nft
	mkdir -p $FIREWALL/group

	_SYSTEM_CONFIGURATION_PATH_SED_SAFE=$(_sed_safe $_CONF_SYSTEM_CONFIGURATION_PATH/devices/)

	_nftables_build_groups
	_nftables_write_groups
	_nftables_write_scheduled_groups
}

_nftables_build_groups() {
	local group_file
	for group_file in $(find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -type f -name .tables); do
		_nftables_build_group
	done
}

_nftables_build_group() {
	_DETAIL "building variable - $group_file"

	local group_name group_dir
	group_dir=$(dirname $group_file)

	local nftables_set_crontab_file=$(_mktemp)

	for group_name in $($_CONF_GNU_GREP -Pv '^($|#)' $group_file | grep -v '|' | sed -e 's/|.*$//' | sort -u); do
		$_CONF_GNU_GREP -Poh '^IP=.*' $group_dir -r |
			sed -e 's/^IP=//' | sort -u >>$FIREWALL/group/$group_name
	done

	local nftables_wrote_table_schedule_header

	local group_line group_start group_end ip_addresses
	$_CONF_GNU_GREP -Pv '^($|#)' $group_file | grep '|' | while read group_line; do
		group_name=$(printf '%s' "$group_line" | cut -f1 -d'|')
		group=$(basename $(dirname $group_file))

		group_start=$(printf '%s' "$group_line" | cut -f2 -d'|' -s)
		group_end=$(printf '%s' "$group_line" | cut -f3 -d'|' -s)

		ip_addresses=$($_CONF_GNU_GREP -Poh '^IP=.*' $group_dir -r | sed -e 's/^IP=//' | sort -u | tr '\n' ',' | sed -e 's/,$//')

		[ -z "$nftables_wrote_table_schedule_header" ] && {
			printf '\n' >>$nftables_set_crontab_file
			printf '# nftables - set schedule - %s.%s\n' "$group_name" "$group" >>$nftables_set_crontab_file
			nftables_wrote_table_schedule_header=1
		}

		_nftables_set_crontab "$group_name" "$ip_addresses" "$group_start" "$group_end" $nftables_set_crontab_file
	done

	_crontab_append root $nftables_set_crontab_file
	rm -f $nftables_set_crontab_file
}

_nftables_write_groups() {
	for group_file in $(find $FIREWALL/group -type f | sort -u); do
		group_name=$(basename $group_file)

		_DETAIL "writing group - $group_name"

		_nftables_write_group_set
	done
}

_nftables_write_scheduled_groups() {
	find $_CONF_SYSTEM_CONFIGURATION_PATH/devices -type f -name .tables -exec $_CONF_GNU_GREP -Pvh '^($|#)' {} + |
		grep '|' | cut -f1 -d'|' | sort -u | while read group_name; do
		[ -e $FIREWALL/group/$group_name ] && {
			_WARN "skipping group - $group_name"
			continue
		}

		_DETAIL "writing scheduled group - $group_name"

		_nftables_write_group_set
	done
}

_nftables_write_group_variable() {
	printf 'define %s = { %s }\n' $group_name "$(cat $group_file | tr '\n' ' ' | sed -e 's/ /, /g' -e 's/, $//')" >>$FIREWALL/variables.nft
}

_nftables_write_group_set() {
	printf 'set group_%s {\n' $group_name >>$FIREWALL/groups.nft
	printf '  type ipv4_addr\n' >>$FIREWALL/groups.nft

	[ -n "$group_file" ] && [ -e $group_file ] && {
		printf '  elements = { %s }\n' "$(cat $group_file | tr '\n' ' ' | sed -e 's/ /, /g' -e 's/, $//')" >>$FIREWALL/groups.nft
	}

	printf '}\n' >>$FIREWALL/groups.nft
	printf '\n' >>$FIREWALL/groups.nft
}

_nftables_set_crontab() {
	[ -n "$3" ] && {
		printf "%s nft add element ip global group_%s '{ %s }' >/dev/null 2>&1\n" "$3" "$1" "$2" >>$5
		printf '\n' >>$5
	}

	[ -n "$4" ] && {
		printf "%s nft delete element ip global group_%s '{ %s }' >/dev/null 2>&1\n" "$4" "$1" "$2" >>$5

		local conntrack_ips=$(printf '%s' "$2" | tr ',' ' ')
		printf "%s conntrack -D -s %s >/dev/null 2>&1\n" "$4" "$conntrack_ips" >>$5
		printf "%s conntrack -D -d %s >/dev/null 2>&1\n" "$4" "$conntrack_ips" >>$5
		printf '\n' >>$5
	}
}
