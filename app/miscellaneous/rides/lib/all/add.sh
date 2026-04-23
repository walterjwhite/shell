_add_exists() {
  [ ! -e $_file ] && return

  $GNU_GREP -cqm1 "^$_date|$_index|$_bike" $_file &&
    exit_with_error "entry already exists, please double-check: $_date|$_index|$_bike - $_file"
}

_add_file() {
  local year=$(printf '%s' $_date | head -c 4)
  _add_decade

  _file=$git_project_path/activity/$_decade/$year.csv
}

_add_decade() {
  _end_year=$(printf '%s' $year | head -c 4 | tail -c 1)
  _event_decade_prefix=$(printf '%s' "$year" | head -c 3)

  if [ "$_end_year" -eq "0" ]; then
    _event_decade_start=$(($_event_decade_prefix - 1))
    _event_decade_end=${_event_decade_prefix}0
  else
    _event_decade_start=$_event_decade_prefix
    _event_decade_end=$(($_event_decade_prefix + 1))
    _event_decade_end="${_event_decade_end}0"
  fi

  _event_decade_start=${_event_decade_start}1

  _decade=${_event_decade_start}-${_event_decade_end}
}

_add_validate_date() {
  case "$_date" in
  [0-9][0-9][0-9][0-9]/[0-9][0-9]/[0-9][0-9])
    _date=$(printf '%s' $_date | sed -e "s/\///g")
    ;;
  [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9])
    ;;
  *)
    exit_with_error "invalid date format: $_date. Expected format: YYYY/mm/dd or YYYYmmdd"
    ;;
  esac
}
