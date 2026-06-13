_buildfile_local_var_names_has_invalid() {
  local invalid_local_vars=$($GNU_GREP -nE '^[[:space:]]*local [a-zA-Z_][a-zA-Z0-9_]*' $buildfile_output_package_file |
    $GNU_SED -E 's/^[0-9]*:[[:space:]]*local //; s/[=\$].*//' | $GNU_GREP -v '^$' |
    tr ' ' '\n' |
    $GNU_SED -E '/^_[a-z][a-z0-9_]*$/d; /^[a-z][a-z0-9_]*$/d' | sort -u)

  [ -z "$invalid_local_vars" ] && return

  log_warn 'invalid local variable names'
  printf '%s\n' "$invalid_local_vars"

  exit_with_error "$buildfile_output_package_file has invalid local variable names (Rule 5: _[a-z][a-z0-9_]+ for parameters or [a-z][a-z0-9_]+ for variables)"
}
