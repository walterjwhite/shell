lib crontab.sh
lib feature:nftables.dynamic.sh
lib feature:nftables.variable.sh

cfg cron

system_configuration_nftables() {
  _firewall=/usr/local/etc/walterjwhite/firewall

  _nftables_clear
  _nftables_build_static_sets

  _nftables_build_variables

  _is_restart_services || return

  nft -cf $_firewall/main.nft && {
    nft flush ruleset &&
      nft -f $_firewall/main.nft
  }
}
