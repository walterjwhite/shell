_pf_build_anchor_schedules() {
	_pf_clear_anchor_schedules

	local pf_anchor_schedule_file=$(_mktemp)

	printf '# pf - anchor schedule\n' >>$pf_anchor_schedule_file

	local anchor_schedule_file pf_anchor_name
	for anchor_schedule_file in $(find $FIREWALL/anchor-schedule -type f); do
		anchor_name=$(basename $anchor_schedule_file)
		pf_anchor_name=$(printf '%s' $anchor_name | tr '.' '_')_scheduled

		_DETAIL "building anchor schedule - $pf_anchor_name"

		local anchor_schedule pf_anchor_file
		$_CONF_GNU_GREP -Pvh '^(#|$)' $anchor_schedule_file | while read anchor_schedule; do
			_DETAIL "building anchor schedule - $pf_anchor_name - $anchor_schedule"

			local anchor_direction
			case $pf_anchor_name in
			i*)
				anchor_direction=internal
				;;
			e*)
				anchor_direction=external
				;;
			*)
				_ERROR "Unknown direction $pf_anchor_name"
				;;
			esac

			pf_anchor_file=$FIREWALL/anchor/$anchor_direction/${anchor_name}.scheduled
			anchor_start=$(printf '%s' "$anchor_schedule" | cut -f1 -d'|')
			anchor_end=$(printf '%s' "$anchor_schedule" | cut -f2 -d'|' -s)

			[ -n "$anchor_start" ] && printf '%s /usr/local/bin/_pfctl -a %s -f %s 2>&1\n' "$anchor_start" $pf_anchor_name $pf_anchor_file >>$pf_anchor_schedule_file
			[ -n "$anchor_end" ] && {
				printf '%s /usr/local/bin/_pfctl -a %s -F all > /dev/null 2>&1\n' "$anchor_end" $pf_anchor_name >>$pf_anchor_schedule_file
				printf '%s /usr/local/bin/_pfctl -a %s -F states > /dev/null 2>&1\n' "$anchor_end" $pf_anchor_name >>$pf_anchor_schedule_file
			}

			printf '\n' >>$pf_anchor_schedule_file
		done
	done

	_crontab_append root $pf_anchor_schedule_file
	rm -f $pf_anchor_schedule_file
}

_pf_clear_anchor_schedules() {
	local existing_crontab=$(_mktemp)

	_crontab_get root $existing_crontab
	$_CONF_GNU_SED -i '/pfctl -a/d' $existing_crontab

	_crontab_write root "$existing_crontab"

	rm -f $existing_crontab
}
