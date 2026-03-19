_buildfile_list_variables() {
  {
    $GNU_GREP -Pho '\$(\{?)[\w]{3,}(:?)=' $1 | sed -e 's/^\${//' -e 's/^\$//' -e 's/:=//' -e 's/=//'
    $GNU_GREP -Pho '^[[:space:]]*[\w]{3,}=' $1 | sed -e 's/^[[:space:]]*//' -e 's/=//'
  } | sort -u
}

_buildfile_used_variables() {
  $GNU_GREP -Po '\$({?)[\w]{3,}' $1 | sed -e 's/^\${//' -e 's/^\$//' | sort -u

  $GNU_GREP -P '^[[:space:]]*(export|set) [\w]{3,}' $1 | $GNU_GREP -Pho '\$(\{?)[\w]{3,}' | sed -e 's/^\${//' -e 's/^\$//'
}

_buildfile_unused_variables() {
  local used_variables=$(_buildfile_used_variables $buildfile_output_package_file | tr '\n' '|' | sed -e 's/^/(/' -e 's/|$//' -e 's/$/)/')
  _buildfile_list_variables $buildfile_output_package_file | $GNU_GREP -Pv "^${used_variables}$"
}


_buildfile_remove_unused_variables() {
  local buildfile_index=0
  while :; do
    local unused_variables=$(_buildfile_unused_variables)

    [ -z "$unused_variables" ] && break

    log_detail "remove cfg:$i:$unused_variables"
    local unused_variable
    for unused_variable in $unused_variables; do
      _buildfile_remove_unused_variable $unused_variable $buildfile_output_package_file
    done

    buildfile_index=$(($buildfile_index + 1))
  done
}

_buildfile_remove_unused_variable() {
  log_warn "unused default: $1"
  $GNU_SED -i "/^[[:space:]]*: \${$1:=.*}$/d" $2
  $GNU_SED -i -E "/^[[:space:]]*((export|readonly|local)[[:space:]]+)?$1=.*/d" $2
}
