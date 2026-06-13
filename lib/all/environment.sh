_environment_variable_is_set() {
  set | grep -cqm1 "^$1=.*$"
}

_environment_filter() {
  $GNU_GREP -P "(^conf_|^optn_|^install_|^${target_application_name}_)"
}

_environment_dump() {
  [ "$conf_log_level" -gt 0 ] && return

  set | sort
}

_environment_export_matching_vars() {
  local _var
  local _oifs
  _oifs=$IFS
  IFS=$'\n'

  for _var in $(set | $GNU_GREP -P "${1}.*=" | sed -e 's/=.*$//'); do
    log_debug "exporting: $_var"
    export "$_var"
  done
  IFS=$_oifs

  [ $conf_log_level -eq 0 ] && set >>$log_logfile.env
}

_environment_export_vars() {
  local _var
  for _var in "$@"; do
    export $_var
  done
}
