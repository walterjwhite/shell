_buildfile_forbidden_exit_calls_has_invalid() {
  case "$buildfile_output_package_file" in
  */bin/*)
    return 0
    ;;
  *run)
    ;;
  *)
    return 0
    ;;
  esac

  local temp_no_comments
  temp_no_comments=$(mktemp)

  sed 's/[[:space:]]*#.*$//' "$buildfile_output_package_file" |
    sed '/^[[:space:]]*#/d' |
    sed 's/[[:space:]]*#.*$//' >"$temp_no_comments"

  local forbidden_matches
  forbidden_matches=$($GNU_GREP -nE '\b(exit|exit_with_error|exit_with_success)\b' "$temp_no_comments" | head -20)

  rm "$temp_no_comments"

  [ -z "$forbidden_matches" ] && return 0

  log_warn 'forbidden exit function calls found in run file'
  printf '%s\n' "$forbidden_matches"

  [ -z "$warn_on_exit_calls" ] && exit_with_error "$buildfile_output_package_file contains forbidden exit function calls (exit, exit_with_error, exit_with_success). Run files must not call exit functions directly."
}
