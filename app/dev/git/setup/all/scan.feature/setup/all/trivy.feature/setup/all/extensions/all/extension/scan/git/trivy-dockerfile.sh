#!/bin/sh

lib feature:.
lib git/data.app.sh
lib git/project.directory.sh
lib scan/git.sh
lib scan/report.sh
lib stdin.sh

_scan_new() {
  _scan_do
}

_scan_delta() {
  _scan_do
}

_scan_do() {
  rm -f "$report_path.new"

  for dockerfile in $(find . -path '*/.build/Dockerfile'); do
    dockerfile=$(realpath --relative-to=. "$dockerfile")

    local _result
    _result=$(trivy -q conf -f json "$dockerfile" 2>/dev/null |
      jq '.Results |= map(. + (if .Target then {"Path": "'"$dockerfile"'"} else {} end))' |
      jq -MSr '.Results[0]' |
      grep -v '^null$')

    [ -z "$_result" ] && continue

    if [ -e "$report_path.new" ]; then
      printf ',\n' >>"$report_path.new"
    fi
    printf '%s\n' "$_result" >>"$report_path.new"
  done

  [ -e "$report_path.new" ] && _trivy_review
}

_scan_run trivy-dockerfile
