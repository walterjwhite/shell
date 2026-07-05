#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"
. "$SCRIPT_DIR/../../lib/dry_run.sh"

. "$SCRIPT_DIR/../../../lib/all/install/npm.sh"
. "$SCRIPT_DIR/../../../lib/all/net/download.sh"

describe "npm: USER install"

test "USER npm install uses no sudo" '
  TARGET_INSTALL_USER=USER
  TARGET_APP_PLATFORM_BIN_PATH=/home/testuser/.local/bin
  with_dry_run "
    _npm_install_do typescript
    assert_not_contains sudo_run \"\$dry_run_log\" \"no sudo for USER\"
    assert_contains npm \"\$dry_run_log\" \"npm recorded\"
    assert_contains --prefix \"\$dry_run_log\" \"prefix present\"
    assert_contains /home/testuser/.local \"\$dry_run_log\" \"HOME-relative prefix\"
  "
'

test "USER npm install passes package name" '
  TARGET_INSTALL_USER=USER
  TARGET_APP_PLATFORM_BIN_PATH=/home/testuser/.local/bin
  with_dry_run "
    _npm_install_do typescript
    assert_contains typescript \"\$dry_run_log\" \"package name passed\"
  "
'

describe "npm: SYSTEM install"

test "SYSTEM npm install uses sudo_run" '
  TARGET_INSTALL_USER=SYSTEM
  TARGET_APP_PLATFORM_BIN_PATH=/usr/local/bin
  with_dry_run "
    _npm_install_do typescript
    assert_contains sudo_run \"\$dry_run_log\" \"sudo_run used\"
    assert_contains /usr/local \"\$dry_run_log\" \"SYSTEM prefix\"
  "
'

describe "npm: uninstall"

test "USER npm uninstall does not use sudo" '
  TARGET_INSTALL_USER=USER
  TARGET_APP_PLATFORM_BIN_PATH=/home/testuser/.local/bin
  with_dry_run "
    _npm_uninstall_do typescript
    assert_not_contains sudo_run \"\$dry_run_log\" \"no sudo for USER\"
    assert_contains uninstall \"\$dry_run_log\" \"uninstall verb\"
  "
'

describe "_download_install_file"

test "USER download does not use sudo" '
  TARGET_INSTALL_USER=USER
  download_file=$(mktemp)
  printf placeholder > "$download_file"
  _install_file_chmod=755
  with_dry_run "
    _download_install_file /home/testuser/.local/bin/mytool
    assert_not_contains sudo_run \"\$dry_run_log\" \"no sudo for USER\"
    assert_contains cp \"\$dry_run_log\" \"cp recorded\"
  "
  rm -f "$download_file"
  unset download_file _install_file_chmod
'

test "SYSTEM download uses sudo for mkdir and cp" '
  TARGET_INSTALL_USER=SYSTEM
  download_file=$(mktemp)
  printf placeholder > "$download_file"
  _install_file_chmod=755
  with_dry_run "
    _download_install_file /usr/local/bin/mytool
    assert_contains sudo_run \"\$dry_run_log\" \"sudo_run used\"
    assert_contains mkdir \"\$dry_run_log\" \"mkdir under sudo\"
    assert_contains cp \"\$dry_run_log\" \"cp under sudo\"
  "
  rm -f "$download_file"
  unset download_file _install_file_chmod
'

describe "_download_fetch"

test "records curl command" '
  TARGET_APP_PLATFORM_CACHE_PATH=/tmp/test_cache_$$
  no_cache=1
  with_dry_run "
    _download_fetch https://example.com/tool-1.0.tar.gz tool-1.0.tar.gz
    assert_contains curl \"\$dry_run_log\" \"curl recorded\"
    assert_contains https://example.com/tool-1.0.tar.gz \"\$dry_run_log\" \"URL passed\"
  "
  unset no_cache TARGET_APP_PLATFORM_CACHE_PATH
'

test "uses provided filename not URL basename" '
  TARGET_APP_PLATFORM_CACHE_PATH=/tmp/test_cache_$$
  no_cache=1
  with_dry_run "
    _download_fetch https://example.com/releases/latest/asset.tar.gz mytool-1.0.tar.gz
    assert_contains mytool-1.0.tar.gz \"\$dry_run_log\" \"provided filename used\"
  "
  unset no_cache TARGET_APP_PLATFORM_CACHE_PATH
'

test "skips curl when file is cached" '
  TARGET_APP_PLATFORM_CACHE_PATH=/tmp/test_cache_$$
  mkdir -p "/tmp/test_cache_$$"
  touch "/tmp/test_cache_$$/tool-1.0.tar.gz"
  unset no_cache
  with_dry_run "
    _download_fetch https://example.com/tool-1.0.tar.gz tool-1.0.tar.gz
    assert_not_contains curl \"\$dry_run_log\" \"curl skipped for cached file\"
  "
  rm -rf "/tmp/test_cache_$$"
  unset TARGET_APP_PLATFORM_CACHE_PATH
'

run_tests
