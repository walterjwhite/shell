#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"
. "$SCRIPT_DIR/../../lib/dry_run.sh"

conf_cron_provider=default
GNU_SED=sed

_crontab_append() { :; }
_crontab_write() { :; }
_crontab_get() { cat /dev/null >"$2"; }
_crontab_target_user() { printf 'testuser'; }
_crontab_run() {
  shift
  "$@"
}
crontab_default_clear() { :; }
crontab_default_get() { cat /dev/null >"$2"; }
crontab_default_write() { :; }

. "$SCRIPT_DIR/../../../app/install/lib/all/install/module/crontab.sh"


_captured_content=""
_capture_crontab_append() { _captured_content=$(cat "$2"); }

_written_content=""
_capture_crontab_write() { _written_content=$(cat "$2"); }


describe "crontab_install: entry marking"

test "marks each cron line with app name comment" '
  target_application_name=myapp
  _captured_content=""
  _crontab_append() { _captured_content=$(cat "$2"); }
  local _src
  _src=$(mktemp)
  printf "0 */4 * * * /usr/local/bin/update-blocks\n" > "$_src"
  crontab_install "$_src"
  assert_contains "# app.myapp" "$_captured_content" "app marker comment added"
  rm -f "$_src"
'

test "prepends header with app name" '
  target_application_name=myapp
  _captured_content=""
  _crontab_append() { _captured_content=$(cat "$2"); }
  local _src
  _src=$(mktemp)
  printf "0 */4 * * * /usr/local/bin/update-blocks\n" > "$_src"
  crontab_install "$_src"
  assert_contains "# app.myapp" "$_captured_content" "header contains app name"
  rm -f "$_src"
'

_check_header_precedes_entries() {
  local _content="$1"
  local _header_line _sched_line
  _header_line=$(printf '%s\n' "$_content" | grep -n "^# app.myapp" | head -1 | cut -d: -f1)
  _sched_line=$(printf '%s\n' "$_content" | grep -n "update-blocks" | head -1 | cut -d: -f1)
  assert_not_empty "$_header_line" "header line found"
  assert_not_empty "$_sched_line" "schedule line found"
  if [ -n "$_header_line" ] && [ -n "$_sched_line" ]; then
    if [ "$_header_line" -lt "$_sched_line" ]; then
      _assert_pass "header precedes entries"
    else
      _assert_fail "header must precede entries (header=$_header_line sched=$_sched_line)"
    fi
  fi
}

test "header appears before cron entries" '
  target_application_name=myapp
  _captured_content=""
  _crontab_append() { _captured_content=$(cat "$2"); }
  local _src
  _src=$(mktemp)
  printf "0 */4 * * * /usr/local/bin/update-blocks\n" > "$_src"
  crontab_install "$_src"
  _check_header_precedes_entries "$_captured_content"
  rm -f "$_src"
'

test "no literal backslash inserted as blank line" '
  target_application_name=myapp
  _captured_content=""
  _crontab_append() { _captured_content=$(cat "$2"); }
  local _src
  _src=$(mktemp)
  printf "0 */4 * * * /usr/local/bin/update-blocks\n" > "$_src"
  crontab_install "$_src"
  assert_not_contains "^\\" "$_captured_content" "no literal backslash in output"
  rm -f "$_src"
'

describe "crontab_uninstall: entry removal"

_make_existing_crontab() {
  local _f
  _f=$(mktemp)
  cat >"$_f" <<'CRON_EOF'

0 */4 * * * /usr/local/bin/update-blocks # app.myapp
0 0 * * * /usr/local/bin/other # app.otherapp
CRON_EOF
  printf '%s' "$_f"
}

test "removes lines marked with app name" '
  target_application_name=myapp
  local _existing
  _existing=$(_make_existing_crontab)
  _crontab_get() { cp "$_existing" "$2"; }
  _written_content=""
  _crontab_write() { _written_content=$(cat "$2"); }
  crontab_uninstall
  assert_not_contains "update-blocks" "$_written_content" "myapp entries removed"
  assert_contains "otherapp" "$_written_content" "other app entries preserved"
  rm -f "$_existing"
'

test "preserves entries from other apps" '
  target_application_name=myapp
  local _existing
  _existing=$(_make_existing_crontab)
  _crontab_get() { cp "$_existing" "$2"; }
  _written_content=""
  _crontab_write() { _written_content=$(cat "$2"); }
  crontab_uninstall
  assert_contains "other" "$_written_content" "other-app line preserved"
  rm -f "$_existing"
'

describe "_crontab_target_user"

test "SYSTEM install targets root" '
  TARGET_INSTALL_USER=SYSTEM
  local _user
  _user=$(_crontab_target_user)
  assert_eq "root" "$_user" "SYSTEM crontab user is root"
'

test "USER install targets current user not root" '
  TARGET_INSTALL_USER=USER
  local _user
  _user=$(_crontab_target_user)
  assert_neq "root" "$_user" "USER crontab user is not root"
'

run_tests
