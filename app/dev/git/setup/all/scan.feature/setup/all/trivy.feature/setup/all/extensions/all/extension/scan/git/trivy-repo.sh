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
  _trivy_scan repo .
}

_scan_run trivy-repo
