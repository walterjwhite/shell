#!/bin/sh

lib git/data.app.sh
lib git/include.sh
lib git/project.directory.sh
lib scan/git.sh
lib scan/report.sh
lib stdin.sh

cfg feature:.

_scan_new() {
  . $conf_dev_detect_secrets_venv/bin/activate

  detect-secrets scan $conf_dev_detect_secrets_exclude_files >$report_path
  _scan_review
}

_scan_delta() {
  . $conf_dev_detect_secrets_venv/bin/activate

  detect-secrets scan --baseline $report_path $conf_dev_detect_secrets_exclude_files
  _scan_review
}

_scan_review() {
  [ $(jq '.results | length' "$report_path") -eq 0 ] && {
    log_info "no findings"
    return
  }

  detect-secrets audit "$report_path"
}

_scan_run detect-secrets json
