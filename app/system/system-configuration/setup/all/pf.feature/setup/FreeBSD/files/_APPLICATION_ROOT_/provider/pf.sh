lib crontab.sh
lib feature:pf.anchor.sh
lib feature:pf.dynamic.sh
lib feature:pf.main.sh
lib feature:pf.table.sh

cfg cron

system_configuration_pf() {
  _firewall=/usr/local/etc/walterjwhite/firewall

  _target=$_firewall/main.pf
  rm -f $_target

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
