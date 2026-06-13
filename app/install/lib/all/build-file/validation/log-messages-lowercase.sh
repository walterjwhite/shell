_buildfile_log_messages_start_lowercase() {
  local invalid_messages
  local line_num
  local message

  invalid_messages=$($GNU_GREP -nE "(log_debug|log_info|log_detail|log_warn|exit_with_error|exit_with_success)\s+['\"][A-Z]" "$buildfile_output_package_file" |
    $GNU_SED -E "s/^([0-9]*).*(log_debug|log_info|log_detail|log_warn|exit_with_error|exit_with_success)\s+['\"]([^'\"]*).*/\1:\2: \3/")

  [ -z "$invalid_messages" ] && return 0

  log_warn 'log messages starting with uppercase letters'
  printf '%s\n' "$invalid_messages"

  exit_with_error "$buildfile_output_package_file has log messages starting with uppercase letters (must start with lowercase)"
}
