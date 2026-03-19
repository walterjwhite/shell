#!/bin/sh

lib git/project.directory.sh
lib stdin.sh

_scan_new() {
  _woke_scan $report_path && return
  cat "$report_path"
  _woke_review
}

_scan_delta() {
  _woke_scan $report_path.new && return

  diff "$report_path.new" "$report_path" && {
    rm $report_path.new
    return
  }

  _woke_review

  mv $report_path.new $report_path
}

_woke_scan() {
  local woke_out_file=$1
  woke -o json | jq -s 'sort_by(.Filename)[]' >"$woke_out_file"
  [ ! -s "$woke_out_file" ] && {
    log_info "woke found no issues"
    rm -f $woke_out_file
    return
  }

  log_warn "woke findings"
  return 1
}

_woke_review() {
  _stdin_continue_if "woke - Do you accept the findings above? (y/n)" || exit_with_error "woke - user aborted"
  log_info "woke - user accepted scan findings"
}

_scan_run woke
