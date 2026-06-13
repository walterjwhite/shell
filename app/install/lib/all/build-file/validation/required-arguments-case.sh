_buildfile_required_arguments_case_has_invalid() {

  local invalid_declarations

  invalid_declarations=$(
    $GNU_GREP -nE '^[[:space:]]*(export[[:space:]]+)?(readonly[[:space:]]+)?[rR]equired[_]?[aA]rguments=' "$buildfile_output_package_file" |
      $GNU_GREP -v '^#' |
      $GNU_GREP -v 'readonly REQUIRED_ARGUMENTS=' |
      $GNU_SED -E 's/^([0-9]+):.*/\1/' |
      sort -u
  )

  [ -z "$invalid_declarations" ] && return

  log_warn 'invalid required_arguments declaration format'
  printf '%s\n' "$invalid_declarations" | while read -r line_num; do
    if [ -n "$line_num" ]; then
      echo "Line $line_num: $(${GNU_SED-n "${line_num}p" "$buildfile_output_package_file"})"
    fi
  done

  exit_with_error "$buildfile_output_package_file has required_arguments declarations that don't follow the required format (must be exactly 'readonly REQUIRED_ARGUMENTS')"
}
