#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"

. "$SCRIPT_DIR/../../../app/install/lib/all/install/module.sh"

describe "install tracking functions"

test "record_path appends path to type tracking" '
  stub_tracking_reset
  stub_exit_reset
  setup_type_name="bin"
  _install_record_path "/usr/local/bin/mytool"
  assert_contains "/usr/local/bin/mytool" "$_stub_type_tracking" \
    "path written to tracking"
'

test "record_dir appends path with trailing slash" '
  stub_tracking_reset
  stub_exit_reset
  setup_type_name="run"
  _install_record_dir "/opt/myapp"
  assert_contains "/opt/myapp/" "$_stub_type_tracking" \
    "dir written with trailing slash"
'

test "record_symlink delegates to record_path" '
  stub_tracking_reset
  stub_exit_reset
  setup_type_name="bin"
  _install_record_symlink "/usr/local/bin/mylink"
  assert_contains "/usr/local/bin/mylink" "$_stub_type_tracking" \
    "symlink written to tracking"
'

test "record_path fails when setup_type_name unset" '
  stub_exit_reset
  unset setup_type_name
  _install_record_path "/some/path"
  assert_not_empty "$_stub_exit_error" \
    "exit_with_error called when setup_type_name unset"
  assert_contains "setup_type_name" "$_stub_exit_error" \
    "error mentions setup_type_name"
'

test "record_dir fails when setup_type_name unset" '
  stub_exit_reset
  unset setup_type_name
  _install_record_dir "/some/dir"
  assert_not_empty "$_stub_exit_error" \
    "exit_with_error called when setup_type_name unset"
'

test "record_path fails when path empty" '
  stub_exit_reset
  setup_type_name="bin"
  _install_record_path ""
  assert_not_empty "$_stub_exit_error" \
    "exit_with_error called when path is empty"
'

run_tests
