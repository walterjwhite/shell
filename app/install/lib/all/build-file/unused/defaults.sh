_buildfile_list_variables() {
  $GNU_GREP -Pho '\$(\{?)[\w]{3,}(:?)=' $1 | sed -e 's/^\${//' -e 's/^\$//' -e 's/:=//' -e 's/=//' | sort -u
}

_buildfile_used_variables() {
  $GNU_GREP -Po '\$({?)[\w]{3,}' $1 | sed -e 's/^\${//' -e 's/^\$//' | sort -u

  grep export $1 | $GNU_GREP -Pho '\$(\{?)[\w]{3,}' | sed -e 's/^\${//' -e 's/^\$//'

  grep set $1 | $GNU_GREP -Pho '\$(\{?)[\w]{3,}' | sed -e 's/^\${//' -e 's/^\$//'
}

_buildfile_unused_variables() {
  local used_variables=$(_buildfile_used_variables $buildfile_output_package_file | tr '\n' '|' | sed -e 's/^/(/' -e 's/|$//' -e 's/$/)/')
  local dynamic_variables=$(_buildfile_dynamic_variables | tr '\n' '|' | sed -e 's/^/(/' -e 's/|$//' -e 's/$/)/')

  local candidates=$(_buildfile_list_variables $buildfile_output_package_file | $GNU_GREP -Pv "^${used_variables}$")

  if [ "$dynamic_variables" != "()" ]; then
    printf '%s\n' "$candidates" | $GNU_GREP -Pv "^${dynamic_variables}$"
  else
    printf '%s\n' "$candidates"
  fi
}

_buildfile_dynamic_variables() {
  $GNU_GREP -Po '_[a-z0-9_]*\$\{[a-z0-9_]+\}[a-z0-9_\$]*' $buildfile_output_package_file |
    sed -e 's/\${[^}]*}/[a-z0-9_]*/g' |
    sort -u
}

_buildfile_remove_unused_variables() {
  local buildfile_index=0
  while :; do
    local unused_variables=$(_buildfile_unused_variables)

    [ -z "$unused_variables" ] && break

    log_debug "remove cfg:$i:$unused_variables"
    local unused_variable
    for unused_variable in $unused_variables; do
      _buildfile_remove_unused_variable $unused_variable $buildfile_output_package_file
    done

    buildfile_index=$(($buildfile_index + 1))
  done
}

_buildfile_remove_unused_variable() {
  log_debug "unused default: $1"
  $GNU_SED -i "/^[[:space:]]*: \${$1:=.*}$/d" $2
  $GNU_SED -i -E "/^[[:space:]]*((export|readonly|local)[[:space:]]+)?$1=.*/d" $2
}
