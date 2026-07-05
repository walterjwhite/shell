#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"
. "$SCRIPT_DIR/../../lib/dry_run.sh"

. "$SCRIPT_DIR/../../../app/install/lib/all/uninstall/uninstall.sh"

_bin_uninstall_called=""
bin_uninstall() {
  _bin_uninstall_called="$_bin_uninstall_called $1"
}

_run_uninstall_called=""
run_uninstall() {
  _run_uninstall_called="$_run_uninstall_called $1"
}

describe "uninstall_app"

test "returns 1 when TARGET_APP_PATH does not exist" '
  _base=/tmp/utest_noexist_$$
  TARGET_APP_PATH="$_base/apps/myapp"
  target_application_name=myapp
  unset clean
  uninstall_app
  assert_eq 1 $? "returns 1 when app path missing"
'

test "returns 1 when .metadata does not exist" '
  _base=/tmp/utest_nometa_$$
  mkdir -p "$_base/apps/myapp"
  TARGET_APP_PATH="$_base/apps/myapp"
  target_application_name=myapp
  unset clean
  uninstall_app
  assert_eq 1 $? "returns 1 when metadata missing"
  rm -rf "$_base"
'

test "removes .metadata and help on uninstall" '
  dry_run_reset
  _base=/tmp/utest_meta_$$
  mkdir -p "$_base/apps/myapp"
  touch "$_base/apps/myapp/.metadata"
  mkdir -p "$_base/apps/myapp/help"
  TARGET_APP_PATH="$_base/apps/myapp"
  target_application_name=myapp
  unset clean
  DRY_RUN_MODE=passthrough uninstall_app
  assert_file_not_exists "$_base/apps/myapp/.metadata" ".metadata removed"
  assert_file_not_exists "$_base/apps/myapp/help" "help dir removed"
  rm -rf "$_base"
'

test "with clean flag removes entire app directory" '
  dry_run_reset
  DRY_RUN_MODE=passthrough
  _base=/tmp/utest_clean_$$
  mkdir -p "$_base/apps/myapp/type"
  touch "$_base/apps/myapp/.metadata"
  touch "$_base/apps/myapp/myfile"
  TARGET_APP_PATH="$_base/apps/myapp"
  target_application_name=myapp
  clean=1
  uninstall_app
  assert_file_not_exists "$_base/apps/myapp" "app dir removed with clean=1"
  unset clean
  DRY_RUN_MODE=record
  rm -rf "$_base"
'

describe "uninstall_type"

test "returns 1 when type directory does not exist" '
  _base=/tmp/utest_notype_$$
  mkdir -p "$_base/apps/myapp"
  TARGET_APP_PATH="$_base/apps/myapp"
  uninstall_type
  assert_eq 1 $? "returns 1 when type dir missing"
  rm -rf "$_base"
'

test "dispatches to correct module uninstall function" '
  _bin_uninstall_called=""
  _base=/tmp/utest_dispatch_$$
  mkdir -p "$_base/apps/myapp/type"
  printf '/usr/local/bin/mytool\n' > "$_base/apps/myapp/type/bin"
  TARGET_APP_PATH="$_base/apps/myapp"
  uninstall_type
  assert_contains "$_base/apps/myapp/type/bin" "$_bin_uninstall_called" \
    "bin_uninstall dispatched with tracking file path"
  rm -rf "$_base"
'

test "dispatches run_uninstall for run type" '
  _run_uninstall_called=""
  _base=/tmp/utest_run_$$
  mkdir -p "$_base/apps/myapp/type"
  printf '/opt/myapp/\n' > "$_base/apps/myapp/type/run"
  TARGET_APP_PATH="$_base/apps/myapp"
  uninstall_type
  assert_contains "$_base/apps/myapp/type/run" "$_run_uninstall_called" \
    "run_uninstall dispatched"
  rm -rf "$_base"
'

test "removes type directory after uninstall" '
  DRY_RUN_MODE=passthrough
  _base=/tmp/utest_rmtype_$$
  mkdir -p "$_base/apps/myapp/type"
  printf '/usr/local/bin/mytool\n' > "$_base/apps/myapp/type/bin"
  TARGET_APP_PATH="$_base/apps/myapp"
  uninstall_type
  assert_file_not_exists "$_base/apps/myapp/type" "type dir removed after uninstall"
  DRY_RUN_MODE=record
  rm -rf "$_base"
'

test "type function name uses no leading underscore" '
  _bin_uninstall_called=""
  _base=/tmp/utest_nounderscore_$$
  mkdir -p "$_base/apps/myapp/type"
  printf '/usr/local/bin/tool\n' > "$_base/apps/myapp/type/bin"
  TARGET_APP_PATH="$_base/apps/myapp"
  uninstall_type
  assert_not_empty "$_bin_uninstall_called" \
    "bin_uninstall called (no leading underscore regression)"
  rm -rf "$_base"
'

run_tests
