_buildfile_remove_unused_variables() {
  local buildfile_preoptimization_snapshot
  buildfile_preoptimization_snapshot=$(mktemp "${buildfile_output_package_file}.preoptimization.XXXXXX") || {
    log_warn "could not create preoptimization snapshot for $buildfile_output_package_file — aborting"
    return 1
  }
  exit_defer rm -f "$buildfile_preoptimization_snapshot"

  cp "$buildfile_output_package_file" "$buildfile_preoptimization_snapshot" || {
    log_warn "could not snapshot $buildfile_output_package_file — aborting"
    rm -f "$buildfile_preoptimization_snapshot"
    return 1
  }

  local buildfile_max_iterations=10
  local iteration=0
  while [ $iteration -lt $buildfile_max_iterations ]; do
    local unused_variables
    unused_variables=$(_buildfile_unused_variables)

    [ -z "$unused_variables" ] && break

    local unused_variable
    for unused_variable in $unused_variables; do
      _buildfile_remove_unused_variable "$unused_variable"
    done

    iteration=$(($iteration + 1))
  done

  [ $iteration -eq $buildfile_max_iterations ] &&
    log_warn "variable removal reached iteration limit ($buildfile_max_iterations) — chain may be deeper than expected"

  local errors
  if errors=$(bash -n "$buildfile_output_package_file" 2>&1); then
    :
  else
    log_warn "syntax check FAILED after variable removal — reverting to preoptimization snapshot"
    log_warn "$errors"
    mv "$buildfile_preoptimization_snapshot" "$buildfile_output_package_file"
    return 1
  fi
}

_buildfile_unused_variables() {
  local used_variables
  used_variables=$(_buildfile_used_variables | tr '\n' '|' | sed -e 's/^/(/' -e 's/|$//' -e 's/$/)/')

  if [ -z "$used_variables" ] || [ "$used_variables" = "()" ]; then
    _buildfile_list_variables
    return
  fi

  _buildfile_list_variables | $GNU_GREP -Pv "^${used_variables}$"
}

_buildfile_used_variables() {
  $GNU_GREP -Po '\$({?)[\w]{3,}' "$buildfile_output_package_file" | sed -e 's/^\${//' -e 's/^\$//' | sort -u

  $GNU_GREP -P '^[[:space:]]*(export|set) [\w]{3,}' "$buildfile_output_package_file" | $GNU_GREP -Pho '\$(\{?)[\w]{3,}' | sed -e 's/^\${//' -e 's/^\$//'
}

_buildfile_list_variables() {
  {
    $GNU_GREP -Pho '\$(\{?)[\w]{3,}(:?)=' "$buildfile_output_package_file" |
      sed -e 's/^\${//' -e 's/^\$//' -e 's/:=//' -e 's/=//'
    $GNU_GREP -Pho '^[[:space:]]*[\w]{3,}=(?=[^[:space:]]*$|[^[:space:]]*[[:space:]]*(#|$))' "$buildfile_output_package_file" |
      sed -e 's/^[[:space:]]*//' -e 's/=//'
    $GNU_GREP -Pho '^[[:space:]]*readonly[[:space:]]+\K[A-Z][A-Z0-9_]{2,}(=\S*)?' "$buildfile_output_package_file" |
      sed -e 's/=.*//'
  } | tr -d '[:blank:]' | sort -u
}


_buildfile_remove_unused_variable() {
  log_warn "unused default: $1"

  $GNU_SED -i -E \
    -e "/^[[:space:]]*: \${$1:=.*}$/d" \
    -e "/^[[:space:]]*((export|readonly|local)[[:space:]]+)?$1\b=.*$/d" \
    -e "/^[[:space:]]*readonly[[:space:]]+$1\b[[:space:]]*(#.*)?$/d" \
    "$buildfile_output_package_file"
}
