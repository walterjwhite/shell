lib install/go.sh

go_dependencies() {
  go get -u
}

go_mod_tidy() {
  go mod tidy
}

go_build_do() {
  if [ $(grep "package main" *.go -n 2>/dev/null | wc -l) -gt 0 ]; then
    log_warn 'building cmd'
    _go_build_cmd
  else
    _go_build_lib
  fi
}

_go_build_lib() {
  go build -a -race $go_build_options
}

_go_build_cmd() {
  _go_walterjwhite_conf

  local error_count=0
  go install -a -race -ldflags "$go_build_options" || error_count=1


  unset _app_name_flag _app_version_flag _scm_id_flag _build_date_flag _go_version_flag _os_architecture_flag go_build_options

  return $error_count
}

go_fix() {
  go fix
}

go_lint() {
  golangci-lint run --fix ./
}

go_vet() {
  go vet
}

go_test() {
  find . -maxdepth 1 -type f -name "*_test.go" -print -quit | grep -cqm1 '.' || {
    return 0
  }

  go test -test.bench=".*"
}
