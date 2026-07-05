#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"

_validate_app_checkout_version() { return 0; }
exit_defer() { :; }

. "$SCRIPT_DIR/../../../app/install/lib/all/validate/validate.sh"

describe "_validate_app_install"

test "returns 0 when type directory absent" '
  stub_log_reset
  TARGET_APP_PATH=/tmp/validate_notype_$$
  mkdir -p "$TARGET_APP_PATH"
  _validate_app_install
  assert_eq 0 $? "returns 0 with no type dir"
  rm -rf "$TARGET_APP_PATH"
'

test "warns about missing tracked file" '
  stub_log_reset
  _base=/tmp/validate_missing_$$
  TARGET_APP_PATH="$_base/apps/myapp"
  mkdir -p "$TARGET_APP_PATH/type"
  printf '/tmp/nonexistent_file_xyz\n' > "$TARGET_APP_PATH/type/bin"
  _validate_app_install
  assert_contains "WRN" "$_stub_log_output" \
    "warning emitted for missing tracked file"
  assert_contains "/tmp/nonexistent_file_xyz" "$_stub_log_output" \
    "missing path named in warning"
  rm -rf "$_base"
'

test "does not warn when all tracked files exist" '
  stub_log_reset
  _base=/tmp/validate_ok_$$
  TARGET_APP_PATH="$_base/apps/myapp"
  mkdir -p "$TARGET_APP_PATH/type"
  local _real_file
  _real_file=$(mktemp)
  printf '%s\n' "$_real_file" > "$TARGET_APP_PATH/type/bin"
  _validate_app_install
  assert_not_contains "WRN" "$_stub_log_output" \
    "no warning when tracked file exists"
  rm -f "$_real_file"
  rm -rf "$_base"
'

test "warns about missing tracked directory" '
  stub_log_reset
  _base=/tmp/validate_missingdir_$$
  TARGET_APP_PATH="$_base/apps/myapp"
  mkdir -p "$TARGET_APP_PATH/type"
  printf '/tmp/nonexistent_dir_xyz/\n' > "$TARGET_APP_PATH/type/run"
  _validate_app_install
  assert_contains "WRN" "$_stub_log_output" \
    "warning emitted for missing tracked directory"
  rm -rf "$_base"
'

test "does not warn when tracked directory exists" '
  stub_log_reset
  _base=/tmp/validate_okdir_$$
  TARGET_APP_PATH="$_base/apps/myapp"
  mkdir -p "$TARGET_APP_PATH/type"
  local _real_dir
  _real_dir=$(mktemp -d)
  printf '%s/\n' "$_real_dir" > "$TARGET_APP_PATH/type/run"
  _validate_app_install
  assert_not_contains "WRN" "$_stub_log_output" \
    "no warning when tracked directory exists"
  rm -rf "$_real_dir" "$_base"
'

test "checks all type tracking files" '
  stub_log_reset
  _base=/tmp/validate_multi_$$
  TARGET_APP_PATH="$_base/apps/myapp"
  mkdir -p "$TARGET_APP_PATH/type"
  local _real_file
  _real_file=$(mktemp)
  printf '%s\n' "$_real_file" > "$TARGET_APP_PATH/type/bin"
  printf '/tmp/missing_run_file_xyz\n' > "$TARGET_APP_PATH/type/run"
  _validate_app_install
  assert_contains "WRN" "$_stub_log_output" \
    "warning for missing run entry"
  assert_contains "missing_run_file_xyz" "$_stub_log_output" \
    "missing run file named"
  rm -f "$_real_file"
  rm -rf "$_base"
'

test "reads from type directory not .files" '
  stub_log_reset
  _base=/tmp/validate_nofiles_$$
  TARGET_APP_PATH="$_base/apps/myapp"
  mkdir -p "$TARGET_APP_PATH/type"
  printf '/tmp/old_files_reference\n' > "$TARGET_APP_PATH/.files"
  _validate_app_install
  assert_not_contains "old_files_reference" "$_stub_log_output" \
    ".files not read by validate"
  rm -rf "$_base"
'

run_tests
