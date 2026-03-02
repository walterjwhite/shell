_report_review_scan_report() {
  local _report_name=$1
  shift

  local _new_report_file=$1
  shift

  local _existing_report_file=$1
  shift

  [ ! -e "$_new_report_file" ] && {
    log_info "$_report_name - report not found"
    return
  }

  if [ $(wc -l <$_new_report_file) -eq 0 ]; then
    log_info "$_report_name - report is empty"
    return
  fi

  log_info "$_report_name - findings"
  cat $_new_report_file

  _stdin_continue_if "$_report_name - Do you accept the findings above? (y/n)" || exit_with_error "$_report_name - user aborted"

  log_info "$_report_name - user accepted scan findings"
  mv "$_new_report_file" "$_existing_report_file"
}
