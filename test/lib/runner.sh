#!/bin/sh

#
#
#
#
#
#

_test_index=0
_test_suite=""

describe() {
  _test_suite="$1"
  _test_index=$((_test_index + 1))
  local _i="$_test_index"
  eval "_test_case_${_i}() { :; }"
  eval "_test_name_${_i}=\$_test_suite"
  eval "_test_is_describe_${_i}=1"
}

test() {
  local _name="$1"
  local _body="$2"
  _test_index=$((_test_index + 1))
  local _i="$_test_index"

  eval "_test_case_${_i}() {
:
${_body}
}"

  eval "_test_name_${_i}=\$_name"
}

run_tests() {
  local _total_pass=0
  local _total_fail=0
  local _total_skip=0
  local _i=1
  local _name _is_desc

  while [ "$_i" -le "$_test_index" ]; do

    eval "_name=\$_test_name_${_i}"

    eval "_is_desc=\${_test_is_describe_${_i}:-0}"
    if [ "$_is_desc" = "1" ]; then
      printf '\n=== %s ===\n' "$_name"
      _i=$((_i + 1))
      continue
    fi

    _test_pass=0
    _test_fail=0
    _test_skipped=0
    _test_log=""
    _test_current="$_name"
    dry_run_log=""
    _stub_exit_error=""
    _stub_log_output=""
    _stub_type_tracking=""

    set +e
    [ -n "$_setup_body" ] && eval "$_setup_body"
    set -e

    set +e
    eval "_test_case_${_i}"
    set -e

    set +e
    [ -n "$_teardown_body" ] && eval "$_teardown_body"
    set -e

    _total_pass=$((_total_pass + _test_pass))
    _total_fail=$((_total_fail + _test_fail))
    _total_skip=$((_total_skip + _test_skipped))

    if [ "$_test_skipped" -gt 0 ]; then
      printf '  skip %s\n' "$_name"
      printf '%b' "$_test_log" | grep SKIP | sed 's/^/      /'
    elif [ "$_test_fail" -eq 0 ]; then
      printf '  ok  %s\n' "$_name"
    else
      printf '  FAIL %s\n' "$_name"
      printf '%b' "$_test_log" | grep FAIL | sed 's/^/      /'
    fi

    _i=$((_i + 1))
  done

  if [ "$_total_skip" -gt 0 ]; then
    printf '\n%d passed, %d failed, %d skipped\n' "$_total_pass" "$_total_fail" "$_total_skip"
  else
    printf '\n%d passed, %d failed\n' "$_total_pass" "$_total_fail"
  fi
  [ "$_total_fail" -eq 0 ]
}


#
_test_skipped=0

skip() {
  local _reason="${1:-no reason given}"
  _test_skipped=$((_test_skipped + 1))
  _test_log="${_test_log}  SKIP  ${_test_current}: ${_reason}\n"
  return 0
}

_skip_if_not_available() {
  command -v "$1" >/dev/null 2>&1 || {
    skip "$1 not available"
    return 0
  }
}

_skip_if_not_root() {
  [ "$(id -u)" -eq 0 ] || {
    skip "requires root"
    return 0
  }
}

_skip_if_root() {
  [ "$(id -u)" -ne 0 ] || {
    skip "must not run as root"
    return 0
  }
}


#
_setup_body=""
_teardown_body=""

setup() {
  _setup_body="$1"
}

teardown() {
  _teardown_body="$1"
}
