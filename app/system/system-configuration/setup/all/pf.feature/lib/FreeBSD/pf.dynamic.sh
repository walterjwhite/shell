_pf_build_dynamic_schedules() {
  _pf_clear_dynamic_schedules
  pf_dynamic_schedule_file=$(_mktemp_mktemp)

  printf '# pf - dynamic schedule\n' >>$pf_dynamic_schedule_file
  printf '* * * * * firewall-update-tables > /dev/null 2>&1\n' >>$pf_dynamic_schedule_file

  _crontab_append root $pf_dynamic_schedule_file
  rm -f $pf_dynamic_schedule_file
}

_pf_clear_dynamic_schedules() {
  local existing_crontab=$(_mktemp_mktemp)

  _crontab_get root $existing_crontab
  $GNU_SED -i '/^$/d' $existing_crontab
  $GNU_SED -i '/pfctl -a/d' $existing_crontab
  $GNU_SED -i '/pfctl -t/d' $existing_crontab
  $GNU_SED -i '/firewall-update-/d' $existing_crontab
  $GNU_SED -i '/# pf - anchor schedule/d' $existing_crontab
  $GNU_SED -i '/# pf - dynamic schedule/d' $existing_crontab
  $GNU_SED -i '/# pf - table schedule/d' $existing_crontab

  _crontab_write root "$existing_crontab"

  rm -f $existing_crontab
}
