#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"
. "$SCRIPT_DIR/../../lib/dry_run.sh"

. "$SCRIPT_DIR/../../../lib/all/install/go.sh"
. "$SCRIPT_DIR/../../../lib/all/install/rust.sh"

describe "go: _go_uninstall_do"

test "removes binary from GOPATH/bin" '
  conf_install_go_path=/home/testuser/.local
  with_dry_run "
    _go_uninstall_do github.com/some/tool@latest
    assert_contains rm \"\$dry_run_log\" \"rm recorded\"
    assert_contains /home/testuser/.local/bin/tool \"\$dry_run_log\" \"correct binary path\"
  "
'

test "strips @version suffix from module path" '
  conf_install_go_path=/home/testuser/.local
  with_dry_run "
    _go_uninstall_do github.com/some/mytool@v1.2.3
    assert_contains mytool \"\$dry_run_log\" \"binary name without @version\"
    assert_not_contains @v1.2.3 \"\$dry_run_log\" \"version suffix removed\"
  "
'

test "strips /vN versioned path suffix" '
  conf_install_go_path=/home/testuser/.local
  with_dry_run "
    _go_uninstall_do github.com/some/mytool/v2
    assert_contains mytool \"\$dry_run_log\" \"binary name without /v2\"
    assert_not_contains /v2 \"\$dry_run_log\" \"/v2 removed\"
  "
'

test "warns when binary not found" '
  stub_log_reset
  conf_install_go_path=/tmp/no_such_gopath_$$
  _go_uninstall_do "github.com/some/tool"
  assert_contains "WRN" "$_stub_log_output" "warning emitted"
'

test "does not call rm when binary missing" '
  conf_install_go_path=/tmp/no_such_gopath_$$
  with_dry_run "
    _go_uninstall_do github.com/some/tool
    assert_not_contains rm \"\$dry_run_log\" \"rm not called for missing binary\"
  "
'

describe "go: _go_is_installed"

test "returns 0 when binary present" '
  local _gp
  _gp=$(mktemp -d)
  mkdir -p "$_gp/bin"
  touch "$_gp/bin/tool"
  conf_install_go_path="$_gp"
  _go_is_installed "github.com/some/tool"
  assert_eq 0 $? "binary found"
  rm -rf "$_gp"
'

test "returns 1 when binary absent" '
  conf_install_go_path=/tmp/empty_gopath_$$
  _go_is_installed "github.com/some/tool"
  assert_eq 1 $? "binary not found"
'

describe "rust: _rust_root_dir"

test "strips /bin from SYSTEM bin path" '
  TARGET_APP_PLATFORM_BIN_PATH=/usr/local/bin
  assert_eq "/usr/local" "$(_rust_root_dir)" "SYSTEM root"
'

test "strips /bin from USER bin path" '
  TARGET_APP_PLATFORM_BIN_PATH=/home/testuser/.local/bin
  assert_eq "/home/testuser/.local" "$(_rust_root_dir)" "USER root"
'

describe "rust: install/uninstall dry-run"

test "install records cargo install with root" '
  TARGET_APP_PLATFORM_BIN_PATH=/home/testuser/.local/bin
  _rust_is_installed() { return 1; }
  with_dry_run "
    _rust_install_do ripgrep
    assert_contains cargo \"\$dry_run_log\" \"cargo recorded\"
    assert_contains install \"\$dry_run_log\" \"install subcommand\"
    assert_contains /home/testuser/.local \"\$dry_run_log\" \"HOME-relative root\"
    assert_contains ripgrep \"\$dry_run_log\" \"crate name\"
  "
'

test "install skips when already installed" '
  stub_log_reset
  TARGET_APP_PLATFORM_BIN_PATH=/home/testuser/.local/bin
  _rust_is_installed() { return 0; }
  with_dry_run "
    _rust_install_do ripgrep
    assert_not_contains cargo install \"\$dry_run_log\" \"cargo install not called\"
  "
  assert_contains "DTL" "$_stub_log_output" "detail logged"
'

test "uninstall records cargo uninstall with root" '
  TARGET_APP_PLATFORM_BIN_PATH=/home/testuser/.local/bin
  with_dry_run "
    _rust_uninstall_do ripgrep
    assert_contains cargo \"\$dry_run_log\" \"cargo recorded\"
    assert_contains uninstall \"\$dry_run_log\" \"uninstall subcommand\"
    assert_contains /home/testuser/.local \"\$dry_run_log\" \"HOME-relative root\"
  "
'

describe "go: USER vs SYSTEM GOPATH"

test "SYSTEM uses /usr/local" '
  TARGET_INSTALL_USER=SYSTEM
  conf_install_go_path=/usr/local
  _go_is_installed() { return 1; }
  with_dry_run "
    _go_install_do github.com/some/tool@latest
    assert_contains /usr/local \"\$dry_run_log\" \"SYSTEM GOPATH\"
  "
'

test "USER uses HOME-relative path" '
  TARGET_INSTALL_USER=USER
  HOME=/home/testuser
  conf_install_go_path=/home/testuser/.local
  _go_is_installed() { return 1; }
  with_dry_run "
    _go_install_do github.com/some/tool@latest
    assert_contains /home/testuser/.local \"\$dry_run_log\" \"USER GOPATH\"
  "
'

run_tests
