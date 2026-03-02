_pf_concat() {
  local _type=$1

  printf '###\n' >>$_target
  printf '# %s\n' "$_type" >>$_target

  if [ -e $_firewall/$_type ]; then
    for _MATCHING_FILE in $(find $_firewall/$_type \( -type f -or -type l \) ! -name 'main.pf' | sort -V); do
      _pf_include_file $_type $_MATCHING_FILE
    done
  fi

  printf '\n' >>$_target
}

_pf_include_file() {
  if [ -z "$2" ]; then
    log_warn "include filename is empty."
    return
  fi

  case $1 in
  anchor | nat-anchor | rdr-anchor)
    local anchor_name=$(basename $2 | sed -e 's/\.generated$//' | tr '.' '_')

    printf '%s %s\n' "$1" "$anchor_name" >>$_target

    case $2 in
    *.scheduled)
      return
      ;;
    *)
      printf 'load anchor %s from "%s"\n\n' "$anchor_name" "$2" >>$_target
      return
      ;;
    esac
    ;;
  table)
    local table_name=$(basename $2 | sed -e 's/\.generated$//' | tr '.' '_')
    printf 'table <%s> persist file "%s"\n' "$table_name" "$2" >>$_target
    return
    ;;
  esac


  printf 'include "%s"\n' "$2" >>$_target
}
