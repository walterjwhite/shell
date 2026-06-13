_buildfile_duplicate_functions_find() {
  local duplicated_functions=$($GNU_GREP -Po '^[_a-zA-Z][_a-zA-Z0-9]*\(\)[[:space:]]*\{' $buildfile_output_package_file | $GNU_SED -e 's/().*//' | uniq -d | sort -u)
  [ -z "$duplicated_functions" ] && return

  log_warn 'duplicated functions'
  printf '%s\n' "$duplicated_functions"

  warn_on_error=1 exit_with_error "duplicated functions are not allowed - $buildfile_output_package_file"
}
