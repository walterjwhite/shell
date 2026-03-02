_nftables_build_variables() {
  rm -rf $_firewall/group $_firewall/groups.nft $_firewall/variables.nft
  mkdir -p $_firewall/group

  _nftables_build_groups
  _nftables_write_groups
  _nftables_write_scheduled_groups
}

_nftables_build_groups() {
  for group_file in $(find $conf_system_configuration_path/devices -type f -name .tables); do
    _nftables_build_group
  done
}

_nftables_build_group() {
  log_detail "building variable - $group_file"
  group_dir=$(dirname $group_file)

  nftables_set_crontab_file=$(_mktemp_mktemp)

  for group_name in $($GNU_GREP -Pv '^($|#)' $group_file | grep -v '|' | sed -e 's/|.*$//' | sort -u); do
    $GNU_GREP -Poh '^_ip=.*' $group_dir -r |
      sed -e 's/^_ip=//' | sort -u >>$_firewall/group/$group_name

    [ ! -s $_firewall/group/$group_name ] && {
      log_warn "empty group file - $_firewall/group/$group_name"
      rm -f $_firewall/group/$group_name
      return
    }
  done

  local nftables_wrote_table_schedule_header

  local group_line group_start group_end ip_addresses
  $GNU_GREP -Pv '^($|#)' $group_file | grep '|' | while read group_line; do
    group_name=$(printf '%s' "$group_line" | cut -f1 -d'|')
    group=$(basename $(dirname $group_file))

    group_start=$(printf '%s' "$group_line" | cut -f2 -d'|' -s)
    group_end=$(printf '%s' "$group_line" | cut -f3 -d'|' -s)

    ip_addresses=$($GNU_GREP -Poh '^_ip=.*' $group_dir -r | sed -e 's/^_ip=//' | sort -u | tr '\n' ',' | sed -e 's/,$//')

    [ -z "$nftables_wrote_table_schedule_header" ] && {
      printf '\n' >>$nftables_set_crontab_file
      printf '# nftables - set schedule - %s.%s\n' "$group_name" "$group" >>$nftables_set_crontab_file
      nftables_wrote_table_schedule_header=1
    }

    _nftables_set_crontab "$group_name" "$ip_addresses" "$group_start" "$group_end" $nftables_set_crontab_file
  done

  [ ! -s $nftables_set_crontab_file ] && {
    log_detail "appending nftables crontab file"
    _crontab_append root $nftables_set_crontab_file
  }

  rm -f $nftables_set_crontab_file
}

_nftables_write_groups() {
  for group_file in $(find $_firewall/group -type f | sort -u); do
    group_name=$(basename $group_file)

    log_add_context $group_name
    log_detail "writing group"

    _nftables_write_group_set
    log_remove_context
  done
}

_nftables_write_scheduled_groups() {
  find $conf_system_configuration_path/devices -type f -name .tables -exec $GNU_GREP -Pvh '^($|#)' {} + |
    grep '|' | cut -f1 -d'|' | sort -u | while read group_name; do
    [ -e $_firewall/group/$group_name ] && {
      log_warn "skipping group - $group_name"
      continue
    }

    log_add_context $group_name
    log_detail "writing scheduled group"

    _nftables_write_group_set
    log_remove_context
  done
}

_nftables_write_group_variable() {
  printf 'define %s = { %s }\n' $group_name "$(cat $group_file | tr '\n' ' ' | sed -e 's/ /, /g' -e 's/, $//')" >>$_firewall/variables.nft
}

_nftables_write_group_set() {
  printf 'set group_%s {\n' $group_name >>$_firewall/groups.nft
  printf '  type ipv4_addr\n' >>$_firewall/groups.nft

  [ -n "$group_file" ] && [ -e $group_file ] && [ -s $_firewall/group/$group_name ] && {
    printf '  elements = { %s }\n' "$(cat $group_file | tr '\n' ' ' | sed -e 's/ /, /g' -e 's/, $//')" >>$_firewall/groups.nft
  }

  printf '}\n' >>$_firewall/groups.nft
  printf '\n' >>$_firewall/groups.nft
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
