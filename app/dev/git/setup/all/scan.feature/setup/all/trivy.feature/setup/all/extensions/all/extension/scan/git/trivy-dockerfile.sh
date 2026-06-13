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
  for dockerfile in $(find . -path '*/.build/Dockerfile'); do
    dockerfile=$(realpath --relative-to=. "$dockerfile")
    _trivy_scan conf -f json "$dockerfile" |
      jq '.Results |= map( (. + ( if .Target then {"Path": "$dockerfile"} else {} end )) )' |
      jq -MSr '.Results[0]' |
      grep -v '^null$' \
        >"$report_path.new.a"

    if [ -e "$report_path.new" ]; then
      printf ',\n' >>"$report_path.new"
      cat "$report_path.new.a" >>"$report_path.new"
      rm -f "$report_path.new.a"
    else
      mv "$report_path.new.a" "$report_path.new"
    fi
  done
}

_scan_run trivy-dockerfile
