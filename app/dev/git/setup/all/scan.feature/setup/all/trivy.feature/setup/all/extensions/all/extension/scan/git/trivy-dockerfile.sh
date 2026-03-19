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
    _trivy_scan conf "$dockerfile"
  done
}

_scan_run trivy-dockerfile
