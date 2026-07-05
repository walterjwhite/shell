#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"
. "$SCRIPT_DIR/../../lib/dry_run.sh"

. "$SCRIPT_DIR/../../../app/install/lib/all/install/install.sh"


_make_pkg_file() {
  local _f
  _f=$(mktemp)
  printf '%s\n' "$@" >"$_f"
  printf '%s' "$_f"
}

_callback_calls=""
_mock_install_callback() {
  _callback_calls="${_callback_calls}${1}
"
  return 0
}

_mock_fail_callback() {
  return 1
}

describe "_install_filter_file_callback"

test "calls callback for each non-blank non-comment line" '
  _callback_calls=""
  stub_tracking_reset
  local _f
  _f=$(_make_pkg_file "jq" "curl" "git")
  setup_type_name=package
  TARGET_APP_PATH=/tmp/test_cb_$$
  mkdir -p "$TARGET_APP_PATH/type"
  _install_filter_file_callback "$_f" _mock_install_callback
  assert_contains "jq" "$_callback_calls" "jq passed to callback"
  assert_contains "curl" "$_callback_calls" "curl passed to callback"
  assert_contains "git" "$_callback_calls" "git passed to callback"
  rm -f "$_f"
  rm -rf /tmp/test_cb_$$
'

test "skips blank lines" '
  _callback_calls=""
  stub_tracking_reset
  local _f
  _f=$(_make_pkg_file "jq" "" "curl")
  setup_type_name=package
  TARGET_APP_PATH=/tmp/test_blank_$$
  mkdir -p "$TARGET_APP_PATH/type"
  _install_filter_file_callback "$_f" _mock_install_callback
  assert_eq "jq
curl
" "$_callback_calls" "only non-blank lines passed"
  rm -f "$_f"
  rm -rf /tmp/test_blank_$$
'

test "skips comment lines" '
  _callback_calls=""
  stub_tracking_reset
  local _f
  _f=$(_make_pkg_file "# this is a comment" "jq" "# another comment" "curl")
  setup_type_name=package
  TARGET_APP_PATH=/tmp/test_comment_$$
  mkdir -p "$TARGET_APP_PATH/type"
  _install_filter_file_callback "$_f" _mock_install_callback
  assert_not_contains "#" "$_callback_calls" "comment lines not passed to callback"
  assert_contains "jq" "$_callback_calls" "real packages still passed"
  rm -f "$_f"
  rm -rf /tmp/test_comment_$$
'

test "warns when callback fails" '
  stub_log_reset
  stub_tracking_reset
  local _f
  _f=$(_make_pkg_file "jq")
  setup_type_name=package
  TARGET_APP_PATH=/tmp/test_fail_$$
  mkdir -p "$TARGET_APP_PATH/type"
  _install_filter_file_callback "$_f" _mock_fail_callback
  assert_contains "WRN" "$_stub_log_output" "warning logged on callback failure"
  assert_contains "jq" "$_stub_log_output" "failed element named in warning"
  rm -f "$_f"
  rm -rf /tmp/test_fail_$$
'

test "does not track element when callback fails" '
  stub_tracking_reset
  stub_log_reset
  local _f
  _f=$(_make_pkg_file "jq")
  setup_type_name=package
  TARGET_APP_PATH=/tmp/test_no_track_$$
  mkdir -p "$TARGET_APP_PATH/type"
  _install_filter_file_callback "$_f" _mock_fail_callback
  assert_empty "$_stub_type_tracking" "failed element not tracked"
  rm -f "$_f"
  rm -rf /tmp/test_no_track_$$
'

describe "_install_uninstall_filter_file_callback"

_mock_uninstall_callback() {
  _callback_calls="${_callback_calls}uninstall:${1}
"
  return 0
}

test "calls uninstall callback for each tracked package" '
  _callback_calls=""
  local _tracking
  _tracking=$(mktemp)
  printf 'jq\ncurl\ngit\n' > "$_tracking"
  setup_type_name=package
  _install_uninstall_filter_file_callback "$_tracking" _mock_uninstall_callback
  assert_contains "uninstall:jq" "$_callback_calls" "jq uninstalled"
  assert_contains "uninstall:curl" "$_callback_calls" "curl uninstalled"
  assert_contains "uninstall:git" "$_callback_calls" "git uninstalled"
  assert_file_not_exists "$_tracking" "tracking file removed after uninstall"
'

test "does nothing when tracking file is empty" '
  _callback_calls=""
  stub_log_reset
  local _tracking
  _tracking=$(mktemp)
  setup_type_name=package
  _install_uninstall_filter_file_callback "$_tracking" _mock_uninstall_callback
  assert_empty "$_callback_calls" "no callbacks for empty tracking file"
  rm -f "$_tracking"
'

test "removes tracking file after uninstall" '
  local _tracking
  _tracking=$(mktemp)
  printf 'jq\n' > "$_tracking"
  setup_type_name=package
  _install_uninstall_filter_file_callback "$_tracking" _mock_uninstall_callback
  assert_file_not_exists "$_tracking" "tracking file removed"
'

run_tests
