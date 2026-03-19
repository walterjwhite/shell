validation_required_arguments() {
  _buildfile_required_arguments_case_has_invalid

  buildfile_required_arguments=$($GNU_GREP -Ph "^readonly REQUIRED_ARGUMENTS=" "$1")
  [ -z "$buildfile_required_arguments" ] && return 1

  printf '%s\n' "$buildfile_required_arguments" >>$buildfile_output_package_file
}

validation_required_cfg() {
  local required_cfg=$($GNU_GREP -Pvh '#.*$' $buildfile_output_package_file |
    $GNU_GREP -Poh '\$conf_[\w_]{3,}' | sed -e 's/^\$//' | sort -u)

  local defaults=$($GNU_GREP -Poh 'conf_[\w]{3,}:?=' $buildfile_output_package_file | sed -e 's/^\$//' -e 's/:=$//' -e 's/=$//' | sort -u | tr '\n' '|' | sed -e 's/|$//' -e 's/^/(/' -e 's/$/)/')

  buildfile_required_app_conf=$(printf '%s\n' "$required_cfg" | $GNU_GREP -Pv "$defaults" | tr '\n' ' ' | sed -e 's/ $//')

  [ -z "$buildfile_required_app_conf" ] && {
    $GNU_SED -i '/^__REQUIRED_APP_CONF_PLACEHOLDER__$/d' $buildfile_output_package_file
    $GNU_SED -i '/^_cfg_validate_required$/d' $buildfile_output_package_file
    return
  }

  $GNU_SED -i "s/^__REQUIRED_APP_CONF_PLACEHOLDER__$/readonly REQUIRED_APP_CONF=\"$buildfile_required_app_conf\"/" $buildfile_output_package_file
}
