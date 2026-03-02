_nftables_update_sets() {

  nftables_dynamic_schedule_file=$(_mktemp_mktemp)

  printf '# nftables - dynamic schedule\n' >>$nftables_dynamic_schedule_file
  printf '* * * * * firewall-update-tables > /dev/null 2>&1\n' >>$nftables_dynamic_schedule_file

  _crontab_append root $nftables_dynamic_schedule_file
  rm -f $nftables_dynamic_schedule_file
}

_nftables_build_dynamic_sets() {
  rm -rf $_firewall/sets.dynamic.nft
  grep -cqm1 nftables_table ./patches/any/networking/security/firewall/nftables.patch/file/usr/local/etc/walterjwhite/network/dynamic-tables.sh || return 1

  local set set_name set_cname_size set_size
  for set_name in $(grep nftables_table ./patches/any/networking/security/firewall/nftables.patch/file/usr/local/etc/walterjwhite/network/dynamic-tables.sh |
    cut -f2 -d= | tr -d '"'); do

    printf 'set dynamic_%s {\n' $set_name >>$_firewall/sets.dynamic.nft
    printf '  type ipv4_addr\n' >>$_firewall/sets.dynamic.nft
    printf '  flags interval, timeout\n' >>$_firewall/sets.dynamic.nft
    printf '  auto-merge\n' >>$_firewall/sets.dynamic.nft
    printf '}\n' >>$_firewall/sets.dynamic.nft
    printf '\n' >>$_firewall/sets.dynamic.nft
  done
}

_nftables_clear() {
  local existing_crontab=$(_mktemp_mktemp)

  _crontab_get root $existing_crontab
  $GNU_SED -i '/^$/d' $existing_crontab

  $GNU_SED -i '/firewall-update-/d' $existing_crontab
  $GNU_SED -i '/nft /d' $existing_crontab
  $GNU_SED -i '/# nftables - dynamic schedule/d' $existing_crontab
  $GNU_SED -i '/# nftables - set schedule/d' $existing_crontab
  $GNU_SED -i '/conntrack/d' $existing_crontab

  _crontab_write root "$existing_crontab"

  rm -f $existing_crontab
}

_nftables_build_static_sets() {
  [ ! -e $_firewall/set ] && return

  rm -rf $_firewall/sets.static.nft
  find $_firewall/set -type f -exec cat {} + >>$_firewall/sets.static.nft
}
