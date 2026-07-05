#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"
. "$SCRIPT_DIR/../../lib/dry_run.sh"

. "$SCRIPT_DIR/../../../app/install/lib/all/install/settings.sh"

describe "_settings_resolve_target_paths"

test "SYSTEM install sets absolute bin path" '
  TARGET_INSTALL_USER=SYSTEM
  APP_PLATFORM_ROOT=/
  target_application_name=myapp
  _settings_resolve_target_paths
  assert_eq "/usr/local/bin" "$TARGET_APP_PLATFORM_BIN_PATH" \
    "SYSTEM bin path"
'

test "SYSTEM install sets app path with app name" '
  TARGET_INSTALL_USER=SYSTEM
  APP_PLATFORM_ROOT=/
  target_application_name=myapp
  _settings_resolve_target_paths
  assert_eq "/usr/local/walterjwhite/apps/myapp" "$TARGET_APP_PATH" \
    "SYSTEM app path includes app name"
'

test "SYSTEM install sets sbin path" '
  TARGET_INSTALL_USER=SYSTEM
  APP_PLATFORM_ROOT=/
  target_application_name=myapp
  _settings_resolve_target_paths
  assert_eq "/usr/local/sbin" "$TARGET_APP_PLATFORM_SBIN_PATH" \
    "SYSTEM sbin path"
'

test "USER install sets HOME-relative bin path" '
  TARGET_INSTALL_USER=USER
  APP_PLATFORM_ROOT=/
  HOME=/home/testuser
  target_application_name=myapp
  _settings_resolve_target_paths
  assert_eq "/home/testuser/.local/bin" "$TARGET_APP_PLATFORM_BIN_PATH" \
    "USER bin path is HOME-relative"
'

test "USER install sets HOME-relative app path" '
  TARGET_INSTALL_USER=USER
  APP_PLATFORM_ROOT=/
  HOME=/home/testuser
  target_application_name=myapp
  _settings_resolve_target_paths
  assert_eq "/home/testuser/.local/walterjwhite/apps/myapp" "$TARGET_APP_PATH" \
    "USER app path is HOME-relative"
'

test "USER install does not set sbin path" '
  TARGET_INSTALL_USER=USER
  APP_PLATFORM_ROOT=/
  HOME=/home/testuser
  target_application_name=myapp
  unset TARGET_APP_PLATFORM_SBIN_PATH
  _settings_resolve_target_paths
  assert_empty "${TARGET_APP_PLATFORM_SBIN_PATH:-}" \
    "USER install has no sbin path"
'

test "chroot install prefixes all SYSTEM paths with root" '
  TARGET_INSTALL_USER=SYSTEM
  APP_PLATFORM_ROOT=/mnt/chroot
  target_application_name=myapp
  _settings_resolve_target_paths
  assert_contains "/mnt/chroot" "$TARGET_APP_PATH" \
    "chroot prefix applied to TARGET_APP_PATH"
  assert_contains "/mnt/chroot" "$TARGET_APP_PLATFORM_BIN_PATH" \
    "chroot prefix applied to bin path"
'

test "empty TARGET_APP_PATH triggers error" '
  stub_exit_reset
  TARGET_INSTALL_USER=USER
  APP_PLATFORM_ROOT=/
  HOME=""
  target_application_name=myapp
  _settings_resolve_target_paths
  assert_not_empty "${TARGET_APP_PATH:-}" \
    "TARGET_APP_PATH must not be empty after resolution"
'

describe "_settings_validate_install_user"

test "SYSTEM install as root passes" '
  stub_exit_reset
  TARGET_INSTALL_USER=SYSTEM
  target_application_name=myapp
  id() { case "$1" in -u) printf "0" ;; esac; }
  _settings_validate_install_user
  assert_empty "$_stub_exit_error" "SYSTEM+root passes validation"
  unset -f id
'

test "SYSTEM install as non-root fails" '
  stub_exit_reset
  TARGET_INSTALL_USER=SYSTEM
  target_application_name=myapp
  id() { case "$1" in -u) printf "1000" ;; esac; }
  _settings_validate_install_user
  assert_not_empty "$_stub_exit_error" "SYSTEM+non-root fails validation"
  assert_contains "root" "$_stub_exit_error" "error mentions root"
  unset -f id
'

test "USER install as non-root passes" '
  stub_exit_reset
  TARGET_INSTALL_USER=USER
  target_application_name=myapp
  id() { case "$1" in -u) printf "1000" ;; esac; }
  _settings_validate_install_user
  assert_empty "$_stub_exit_error" "USER+non-root passes validation"
  unset -f id
'

test "USER install as root fails with helpful message" '
  stub_exit_reset
  TARGET_INSTALL_USER=USER
  target_application_name=myapp
  id() { case "$1" in -u) printf "0" ;; esac; }
  _settings_validate_install_user
  assert_not_empty "$_stub_exit_error" "USER+root fails validation"
  assert_contains "sudo -u" "$_stub_exit_error" \
    "error suggests sudo -u workaround"
  unset -f id
'

run_tests

describe "INSTALL_USER_OVERRIDE"

test "SYSTEM app overridden to USER resolves HOME paths" '
  stub_exit_reset
  TARGET_INSTALL_USER=SYSTEM
  INSTALL_USER_OVERRIDE=USER
  APP_PLATFORM_ROOT=/
  HOME=/home/testuser
  target_application_name=myapp
  id() { case "$1" in -u) printf "1000" ;; esac; }
  _settings_application_defaults() { :; }
  _include_optional() { :; }
  mkdir() { :; }
  _settings_validate_install_user
  _settings_resolve_target_paths
  assert_eq "USER" "$TARGET_INSTALL_USER" \
    "TARGET_INSTALL_USER changed to USER"
  assert_contains "/home/testuser" "$TARGET_APP_PATH" \
    "TARGET_APP_PATH is HOME-relative after override"
  assert_not_contains "/usr/local" "$TARGET_APP_PATH" \
    "SYSTEM path not used after USER override"
  unset INSTALL_USER_OVERRIDE
  unset -f id mkdir
'

test "USER app overridden to SYSTEM resolves absolute paths" '
  stub_exit_reset
  TARGET_INSTALL_USER=USER
  INSTALL_USER_OVERRIDE=SYSTEM
  APP_PLATFORM_ROOT=/
  target_application_name=myapp
  id() { case "$1" in -u) printf "0" ;; esac; }
  _settings_validate_install_user
  _settings_resolve_target_paths
  assert_eq "SYSTEM" "$TARGET_INSTALL_USER" \
    "TARGET_INSTALL_USER changed to SYSTEM"
  assert_contains "/usr/local" "$TARGET_APP_PATH" \
    "TARGET_APP_PATH is absolute after SYSTEM override"
  unset INSTALL_USER_OVERRIDE
  unset -f id
'

test "invalid INSTALL_USER_OVERRIDE value triggers error" '
  stub_exit_reset
  TARGET_INSTALL_USER=USER
  INSTALL_USER_OVERRIDE=BOGUS
  install_user=USER
  APP_PLATFORM_ROOT=/
  target_application_name=myapp
  registry_path=/tmp
  case "$INSTALL_USER_OVERRIDE" in
  SYSTEM | USER) : ;;
  *) exit_with_error "invalid INSTALL_USER_OVERRIDE value'"'"'$INSTALL_USER_OVERRIDE'"'"' — must be SYSTEM or USER" ;;
  esac
  assert_not_empty "$_stub_exit_error" "error triggered for invalid override"
  assert_contains "BOGUS" "$_stub_exit_error" "invalid value named in error"
  unset INSTALL_USER_OVERRIDE
'

test "no INSTALL_USER_OVERRIDE uses registry value unchanged" '
  stub_exit_reset
  unset INSTALL_USER_OVERRIDE
  APP_PLATFORM_ROOT=/
  HOME=/home/testuser
  target_application_name=myapp
  id() { case "$1" in -u) printf "1000" ;; esac; }
  install_user=USER
  TARGET_INSTALL_USER=USER
  _settings_validate_install_user
  _settings_resolve_target_paths
  assert_eq "USER" "$TARGET_INSTALL_USER" \
    "TARGET_INSTALL_USER unchanged when no override"
  unset -f id
'

test "INSTALL_USER_OVERRIDE is exported for child processes" '
  stub_exit_reset
  unset INSTALL_USER_OVERRIDE
  INSTALL_USER_OVERRIDE=USER
  TARGET_INSTALL_USER=SYSTEM
  case "$INSTALL_USER_OVERRIDE" in
  SYSTEM | USER)
    if [ "$INSTALL_USER_OVERRIDE" != "$TARGET_INSTALL_USER" ]; then
      TARGET_INSTALL_USER="$INSTALL_USER_OVERRIDE"
    fi
    export INSTALL_USER_OVERRIDE
    ;;
  esac
  local _child_value
  _child_value=$(sh -c "printf '%s' \"$INSTALL_USER_OVERRIDE\"")
  assert_eq "USER" "$_child_value" \
    "INSTALL_USER_OVERRIDE visible in child process"
  unset INSTALL_USER_OVERRIDE
'
