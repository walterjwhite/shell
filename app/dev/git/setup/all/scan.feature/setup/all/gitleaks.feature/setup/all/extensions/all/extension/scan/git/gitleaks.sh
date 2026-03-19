#!/bin/sh

lib git/data.app.sh
lib git/project.directory.sh
lib scan/git.sh
lib scan/report.sh
lib stdin.sh

_scan_new() {
  gitleaks detect --report-path $report_path
}

_scan_delta() {
  log_info "commit hash changed, updating report"

  gitleaks detect --log-opts="$scan_last_commit..HEAD" --report-path $report_path.delta

  if [ -s $report_path.delta ]; then
    log_info "delta scan found issues, reviewing"
    _report_review_scan_report "gitleaks" "$report_path.delta" "$report_path"
  else
    log_info "delta scan found no issues"
    rm -f $report_path.delta
  fi
}

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

_scan_run gitleaks json
