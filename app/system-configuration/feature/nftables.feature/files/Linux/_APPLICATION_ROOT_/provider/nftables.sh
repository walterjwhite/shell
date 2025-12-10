lib crontab.sh
lib feature:nftables.dynamic.sh
lib feature:nftables.variable.sh
lib sed.sh

cfg cron

system_configuration_nftables() {
	FIREWALL=/usr/local/etc/walterjwhite/firewall

	_nftables_clear
	_nftables_build_static_sets

	_nftables_build_variables
	_nftables_update_sets

	_is_restart_services || return

	nft -cf $FIREWALL/main.nft && {
		nft flush ruleset &&
			nft -f $FIREWALL/main.nft
	}
}
