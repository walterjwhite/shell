lib crontab.sh
lib feature:pf.anchor.sh
lib feature:pf.dynamic.sh
lib feature:pf.main.sh
lib feature:pf.table.sh
lib sed.sh

cfg cron

system_configuration_pf() {
	FIREWALL=/usr/local/etc/walterjwhite/firewall

	_TARGET=$FIREWALL/rules.pf
	rm -f $_TARGET

	_pf_build_dynamic_schedules
	_pf_build_anchor_schedules

	_pf_build_tables


	_pf_concat policy

	_pf_concat table
	_pf_concat pre-rule

	_pf_concat nat-anchor
	_pf_concat rdr-anchor
	_pf_concat anchor

	_pf_concat post-rule

	_is_restart_services || return

	service pf check && service pf restart
}
