#!/bin/sh

#

_test_pass=0
_test_fail=0
_test_log=""
_test_current="" # name of the currently-running test


_assert_pass() {
  _test_pass=$((_test_pass + 1))
  _test_log="${_test_log}  PASS  ${_test_current}: $1\n"
}

_assert_fail() {
  _test_fail=$((_test_fail + 1))
  _test_log="${_test_log}  FAIL  ${_test_current}: $1\n"
}


assert_eq() {
  local _exp="$1" _act="$2" _msg="${3:-eq}"
  if [ "$_exp" = "$_act" ]; then
    _assert_pass "$_msg"
  else
    _assert_fail "$_msg
         expected: $(printf '%s' "$_exp" | head -5)
           actual: $(printf '%s' "$_act" | head -5)"
  fi
}

assert_neq() {
  local _nexp="$1" _act="$2" _msg="${3:-neq}"
  if [ "$_nexp" != "$_act" ]; then
    _assert_pass "$_msg"
  else
    _assert_fail "$_msg — expected values to differ but both are: $_act"
  fi
}

assert_contains() {
  local _sub="$1" _str="$2" _msg="${3:-contains}"
  case "$_str" in
  *"$_sub"*) _assert_pass "$_msg" ;;
  *) _assert_fail "$_msg
         string: $_str
    missing substring: $_sub" ;;
  esac
}

assert_not_contains() {
  local _sub="$1" _str="$2" _msg="${3:-not_contains}"
  case "$_str" in
  *"$_sub"*) _assert_fail "$_msg — string should not contain: $_sub" ;;
  *) _assert_pass "$_msg" ;;
  esac
}

assert_empty() {
  local _val="$1" _msg="${2:-empty}"
  if [ -z "$_val" ]; then
    _assert_pass "$_msg"
  else
    _assert_fail "$_msg — expected empty but got: $_val"
  fi
}

assert_not_empty() {
  local _val="$1" _msg="${2:-not_empty}"
  if [ -n "$_val" ]; then
    _assert_pass "$_msg"
  else
    _assert_fail "$_msg — expected non-empty value"
  fi
}

assert_ok() {
  local _msg="${2:-ok: $1}"
  if eval "$1" >/dev/null 2>&1; then
    _assert_pass "$_msg"
  else
    _assert_fail "$_msg (exit $?)"
  fi
}

assert_fail() {
  local _msg="${2:-fail: $1}"
  if eval "$1" >/dev/null 2>&1; then
    _assert_fail "$_msg — expected failure but exited 0"
  else
    _assert_pass "$_msg"
  fi
}

assert_file_exists() {
  local _path="$1" _msg="${2:-file_exists: $1}"
  if [ -e "$_path" ]; then
    _assert_pass "$_msg"
  else
    _assert_fail "$_msg — path does not exist: $_path"
  fi
}

assert_file_not_exists() {
  local _path="$1" _msg="${2:-file_not_exists: $1}"
  if [ -e "$_path" ]; then
    _assert_fail "$_msg — path should not exist: $_path"
  else
    _assert_pass "$_msg"
  fi
}

assert_file_contains() {
  local _path="$1" _pat="$2" _msg="${3:-file_contains: $2 in $1}"
  if [ ! -f "$_path" ]; then
    _assert_fail "$_msg — file not found: $_path"
  elif grep -qF "$_pat" "$_path" 2>/dev/null; then
    _assert_pass "$_msg"
  else
    _assert_fail "$_msg — pattern not found in $_path"
  fi
}

assert_dry_run_recorded() {
  local _exp="$1" _msg="${2:-dry_run_recorded}"
  local _last
  _last=$(printf '%s' "$dry_run_log" | tail -1)
  assert_eq "$_exp" "$_last" "$_msg"
}

assert_dry_run_contains() {
  local _sub="$1" _msg="${2:-dry_run_contains: $1}"
  assert_contains "$_sub" "$dry_run_log" "$_msg"
}
