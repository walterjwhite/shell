_pf_build_tables() {
  rm -rf $_firewall/group $_firewall/table/*.generated && mkdir -p $_firewall/group $_firewall/table
  for table_file in $(find $conf_system_configuration_path -type f -name .tables); do
    _pf_build_table_for_group
  done
}

_pf_build_table_for_group() {
  local group_path=$(dirname $table_file)
  local group_name=$(printf '%s' "$table_file" | sed -e "s|$conf_system_configuration_path/devices/||" -e 's/\.tables//' -e 's/\//-/g' -e 's/-$//')

  pf_group_file=$_firewall/group/$group_name
  _pf_table_populate $group_path $pf_group_file

  local table_line table_name pf_table_file table_start table_end index
  pf_table_crontab_file=$(_mktemp_mktemp)

  pf_wrote_table_schedule_header

  log_detail "building table schedule - $group_name"

  $GNU_GREP -Pvh '^($|#)' $table_file | while read table_line; do
    table_name=$(printf '%s' "$table_line" | cut -f1 -d'|')

    table_start=$(printf '%s' "$table_line" | cut -f2 -d'|' -s)
    table_end=$(printf '%s' "$table_line" | cut -f3 -d'|' -s)

    log_detail "building table schedule - $group_name - $table_name - $table_line"

    if [ -z "$table_start" ] && [ -z "$table_end" ]; then
      _pf_table_static "$table_name"
    else
      [ -z "$pf_wrote_table_schedule_header" ] && {
        printf '# pf - table schedule - %s - %s\n' "$group_name" "$table_name" >>$pf_table_crontab_file
        pf_wrote_table_schedule_header=1
      }

      _pf_table_crontab "$table_name" "$group_name" "$table_start" "$table_end" $pf_table_crontab_file
    fi
  done

  _crontab_append root $pf_table_crontab_file
  rm -f $pf_table_crontab_file
}

_pf_table_populate() {
  mkdir -p $(dirname $2)

  find $1 -type f ! -name '.tables' ! -name '*device' \
    -exec $GNU_GREP -Poh '^_ip=.*' {} + |
    sed -e 's/^_ip=//' | sort -u >>$2
}

_pf_table_static() {
  cat $pf_group_file >>$_firewall/table/$1.generated
}

_pf_table_crontab() {
  [ -n "$3" ] && printf '%s /usr/local/bin/_pfctl -t %s -T add -f %s > /dev/null 2>&1\n' "$3" "$1" "$pf_group_file" >>$5
  [ -n "$4" ] && printf '%s /usr/local/bin/_pfctl -t %s -T del -f %s > /dev/null 2>&1\n' "$4" "$1" "$pf_group_file" >>$5

  printf '\n' >>$5
}
