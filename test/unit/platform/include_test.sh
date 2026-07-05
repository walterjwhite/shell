#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"

. "$SCRIPT_DIR/../../../lib/all/include.sh"

describe "_include_optional: path resolution"

test "sources file given as absolute path" '
  local _f
  _f=$(mktemp)
  printf '_test_sourced_abs=1\n' > "$_f"
  unset _test_sourced_abs
  _include_optional "$_f"
  assert_eq "1" "${_test_sourced_abs:-}" "absolute path file was sourced"
  rm -f "$_f"
'

test "returns 0 on success" '
  local _f
  _f=$(mktemp)
  _include_optional "$_f"
  assert_eq 0 $? "returns 0 on successful source"
  rm -f "$_f"
'

test "returns non-zero when file not found" '
  _include_optional "/tmp/no_such_file_xyz_$$"
  assert_neq 0 $? "returns non-zero when file missing"
'

test "searches APP_PLATFORM_CONFIG_PATH for bare name" '
  local _cfg_dir
  _cfg_dir=$(mktemp -d)
  APP_PLATFORM_CONFIG_PATH="$_cfg_dir"
  printf '_test_sourced_cfg=1\n' > "$_cfg_dir/myapp"
  unset _test_sourced_cfg
  _include_optional "myapp"
  assert_eq "1" "${_test_sourced_cfg:-}" \
    "file found in APP_PLATFORM_CONFIG_PATH"
  rm -rf "$_cfg_dir"
  unset APP_PLATFORM_CONFIG_PATH
'

test "falls back to HOME/.config when not in APP_PLATFORM_CONFIG_PATH" '
  local _home_dir
  _home_dir=$(mktemp -d)
  mkdir -p "$_home_dir/.config/walterjwhite/shell"
  printf '_test_sourced_home=1\n' > "$_home_dir/.config/walterjwhite/shell/myapp"
  APP_PLATFORM_CONFIG_PATH=/tmp/no_such_cfg_dir_$$
  HOME="$_home_dir"
  unset _test_sourced_home
  _include_optional "myapp"
  assert_eq "1" "${_test_sourced_home:-}" \
    "file found in HOME/.config fallback"
  rm -rf "$_home_dir"
  unset APP_PLATFORM_CONFIG_PATH
'

test "APP_PLATFORM_CONFIG_PATH takes precedence over HOME/.config" '
  local _cfg_dir _home_dir
  _cfg_dir=$(mktemp -d)
  _home_dir=$(mktemp -d)
  mkdir -p "$_home_dir/.config/walterjwhite/shell"
  printf '_test_source_location=cfg_path\n' > "$_cfg_dir/myapp"
  printf '_test_source_location=home_path\n' > "$_home_dir/.config/walterjwhite/shell/myapp"
  APP_PLATFORM_CONFIG_PATH="$_cfg_dir"
  HOME="$_home_dir"
  unset _test_source_location
  _include_optional "myapp"
  assert_eq "cfg_path" "${_test_source_location:-}" \
    "APP_PLATFORM_CONFIG_PATH takes precedence"
  rm -rf "$_cfg_dir" "$_home_dir"
  unset APP_PLATFORM_CONFIG_PATH
'

test "APP_PLATFORM_CONFIG_PATH expansion not a literal backslash-escaped string" '
  local _cfg_dir
  _cfg_dir=$(mktemp -d)
  APP_PLATFORM_CONFIG_PATH="$_cfg_dir"
  printf '_test_expansion_works=1\n' > "$_cfg_dir/testcfg"
  unset _test_expansion_works
  _include_optional "testcfg"
  assert_eq "1" "${_test_expansion_works:-}" \
    "APP_PLATFORM_CONFIG_PATH expanded (not literal backslash)"
  rm -rf "$_cfg_dir"
  unset APP_PLATFORM_CONFIG_PATH
'

test "sources multiple files in order" '
  local _f1 _f2
  _f1=$(mktemp)
  _f2=$(mktemp)
  printf '_test_order="$_test_order:f1"\n' > "$_f1"
  printf '_test_order="$_test_order:f2"\n' > "$_f2"
  _test_order=""
  _include_optional "$_f1" "$_f2"
  assert_contains ":f1" "$_test_order" "first file sourced"
  assert_contains ":f2" "$_test_order" "second file sourced"
  case "$_test_order" in
  *:f1*:f2*) _assert_pass "files sourced in order" ;;
  *)          _assert_fail "files not in order: $_test_order" ;;
  esac
  rm -f "$_f1" "$_f2"
'

test "counts missing files in inc_err" '
  _include_optional "/tmp/missing1_$$" "/tmp/missing2_$$"
  assert_neq 0 $? "non-zero return when files missing"
'

run_tests
