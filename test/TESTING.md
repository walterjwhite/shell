# Testing Guide

## Running tests

### Run everything

```sh
./test/run_tests.sh
```

### Run a subtree

```sh
./test/run_tests.sh unit            # all unit tests
./test/run_tests.sh unit/install    # only install unit tests
./test/run_tests.sh unit/module     # only module unit tests
./test/run_tests.sh integration     # only integration tests
```

### Run a single file

```sh
./test/run_tests.sh -f test/unit/platform/platform_test.sh
```

### Verbose output (show passing assertions too)

```sh
./test/run_tests.sh -v
```

### Exit codes

| Code | Meaning                       |
| ---- | ----------------------------- |
| 0    | All test files passed         |
| 1    | One or more files failed      |
| 2    | Usage error or no files found |

---

## Repository layout

```
test/
├── run_tests.sh              ← top-level runner (run this)
├── lib/
│   ├── runner.sh             ← test/describe/setup/teardown/skip/run_tests
│   ├── assert.sh             ← all assertion functions
│   ├── dry_run.sh            ← command interception for dry-run tests
│   └── fixtures.sh           ← stubs, helpers, setup_target_paths
├── unit/
│   ├── install/              ← tests for app/install/lib/all/install/*.sh
│   ├── module/               ← tests for app/install/lib/all/install/module/*.sh
│   └── platform/             ← tests for lib/all/*.sh (platform, include, etc.)
└── integration/              ← multi-module tests that exercise a full pipeline
```

Test files are named `*_test.sh` and discovered automatically by `run_tests.sh`.

---

## Writing a new test file

Every test file follows the same five-line structure:

```sh
#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"   # adjust depth to reach test/lib/
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"

# source ONLY the file under test — not the whole binary
. "$SCRIPT_DIR/../../../lib/all/platform.sh"

describe "my feature"

test "does the right thing" '
  assert_eq "expected" "$actual" "message"
'

run_tests
```

Place the file under the appropriate `test/unit/<area>/` directory and name it
`<feature>_test.sh`. The runner discovers it automatically.

---

## The test API

### `describe "group name"`

Prints a section header in the output. Cosmetic — does not affect pass/fail.
Groups the tests that follow it. Can be used multiple times in one file.

```sh
describe "path resolution"

test "SYSTEM sets /usr/local/bin" '...'
test "USER sets HOME-relative bin" '...'

describe "validation"

test "rejects non-root for SYSTEM" '...'
```

### `test "name" 'body'`

Registers a test case. The body is a single-quoted string of sh commands.
It runs after `run_tests` is called, not immediately.

```sh
test "platform_is_supported accepts current platform" '
  APP_PLATFORM_PLATFORM=Linux
  platform_is_supported "FreeBSD Linux Apple"
  assert_empty "$_stub_exit_error" "Linux accepted"
'
```

**Important:** do not put single quotes inside the body string — the shell
interprets them as ending the argument. Extract complex logic into named
helper functions defined outside `test()`:

```sh
# helper defined outside test()
_check_path_prefix() {
  case "$1" in
  /usr/local/*) _assert_pass "SYSTEM prefix correct" ;;
  *)            _assert_fail "expected /usr/local/*, got: $1" ;;
  esac
}

test "SYSTEM path has correct prefix" '
  TARGET_INSTALL_USER=SYSTEM
  _settings_resolve_target_paths
  _check_path_prefix "$TARGET_APP_PATH"
'
```

### `setup 'body'` and `teardown 'body'`

Run before and after each test in the file. Use for shared fixtures like
temporary directories.

```sh
_base=""
setup '
  _base=$(mktemp -d)
  setup_target_paths "$_base"
'
teardown '
  teardown_target_paths "$_base"
  rm -rf "$_base"
'

test "bin_install writes to TARGET_APP_PLATFORM_BIN_PATH" '
  # _base and TARGET_* are already set by setup
  ...
'
```

### `skip "reason"`

Call at the top of a test body to skip the test when a precondition is not
met. The test is shown as `skip` in output and not counted as pass or fail.
Always use with `return 0` via the provided helpers or in a conditional:

```sh
test "requires curl" '
  _skip_if_not_available curl
  # rest of test only runs when curl is present
  ...
'

test "requires root" '
  _skip_if_not_root
  ...
'

test "must not run as root" '
  _skip_if_root
  ...
'

# Manual form for any condition:
test "requires specific binary" '
  command -v myspecialtool >/dev/null 2>&1 || {
    skip "myspecialtool not installed"
    return 0
  }
  ...
'
```

### `run_tests`

Must be the last line of every test file. Executes all registered tests and
prints the report.

---

## Assertions

All assertions take an optional final argument as a message shown on failure.

| Assertion                                 | Passes when                            |
| ----------------------------------------- | -------------------------------------- |
| `assert_eq A B "msg"`                     | `"$A" = "$B"`                          |
| `assert_neq A B "msg"`                    | `"$A" != "$B"`                         |
| `assert_contains SUB STR "msg"`           | STR contains SUB                       |
| `assert_not_contains SUB STR "msg"`       | STR does not contain SUB               |
| `assert_empty VAL "msg"`                  | `"$VAL"` is empty                      |
| `assert_not_empty VAL "msg"`              | `"$VAL"` is non-empty                  |
| `assert_ok "CMD" "msg"`                   | CMD exits 0                            |
| `assert_fail "CMD" "msg"`                 | CMD exits non-zero                     |
| `assert_file_exists PATH "msg"`           | path exists on disk                    |
| `assert_file_not_exists PATH "msg"`       | path does not exist                    |
| `assert_file_contains PATH PATTERN "msg"` | file contains fixed string             |
| `assert_dry_run_contains SUB "msg"`       | `$dry_run_log` contains SUB            |
| `assert_dry_run_recorded CMD "msg"`       | last line of `$dry_run_log` equals CMD |

---

## Stubs and isolation

The framework intercepts the framework's own functions so tests never
accidentally call the real `exit`, write to real log files, or hit the network.

### `exit_with_error`

The real function exits the process. The stub sets `$_stub_exit_error` and
returns 1. Check it with `assert_not_empty "$_stub_exit_error"`.

```sh
test "rejects invalid value" '
  stub_exit_reset
  my_function_that_validates "BAD_VALUE"
  assert_not_empty "$_stub_exit_error" "error triggered"
  assert_contains "BAD_VALUE" "$_stub_exit_error" "value named in error"
'
```

`stub_exit_reset` clears `$_stub_exit_error`. It is called automatically
between tests so you only need it if checking multiple errors in one test.

### `log_warn`, `log_info`, `log_detail`, `log_debug`

All write to `$_stub_log_output` instead of the terminal. Check log messages:

```sh
test "warns when file missing" '
  stub_log_reset
  my_function_with_missing_file "/no/such/file"
  assert_contains "WRN" "$_stub_log_output" "warning emitted"
  assert_contains "/no/such/file" "$_stub_log_output" "path named in warning"
'
```

### `validation_require`

Calls the stubbed `exit_with_error` when the value is empty, so tests can
check validation without the process exiting.

### `_install_setup_type_append`

Writes to `$_stub_type_tracking` instead of the real type directory. Check
what was tracked:

```sh
test "path is tracked after install" '
  stub_tracking_reset
  setup_type_name=bin
  _install_record_path "/usr/local/bin/mytool"
  assert_contains "/usr/local/bin/mytool" "$_stub_type_tracking" "path tracked"
'
```

---

## Path fixtures

`setup_target_paths BASE` sets all `TARGET_*` variables to paths under BASE
so module functions have real-looking destinations without touching the
actual filesystem.

```sh
_base=$(mktemp -d)
setup_target_paths "$_base"

# Now these are set:
# TARGET_APP_PATH          = $base/apps/testapp
# TARGET_APP_PLATFORM_BIN_PATH = $base/bin
# TARGET_APP_PLATFORM_SBIN_PATH = $base/sbin
# TARGET_APP_CONFIG_PATH   = $base/config/testapp
# ... etc.

teardown_target_paths "$_base"
rm -rf "$_base"
```

`make_fixture_app DIR [install_user]` creates a minimal registry-style app
fixture with a `.app` file, a bin script, and a package list:

```sh
_app=$(mktemp -d)
make_fixture_app "$_app" USER
# creates: $_app/.app, $_app/Linux/setup/bin/mybin, $_app/Linux/setup/package/packages
```

---

## Dry-run testing

Dry-run testing answers "what commands would be run?" without executing them.
It is the right approach for testing install functions that call `sudo`, `npm`,
`cargo`, `curl`, `tar`, etc.

Use `with_dry_run "body"` to scope interception to one block. Commands inside
the body are recorded to `$dry_run_log` but not executed. After the block,
the real commands are restored so subsequent tests are unaffected.

```sh
test "USER npm install does not use sudo" '
  TARGET_INSTALL_USER=USER
  TARGET_APP_PLATFORM_BIN_PATH=/home/w/.local/bin
  with_dry_run "
    _npm_install_do typescript
    assert_not_contains sudo_run \"\$dry_run_log\" \"no sudo for USER\"
    assert_contains npm \"\$dry_run_log\" \"npm was called\"
    assert_contains --prefix \"\$dry_run_log\" \"prefix flag present\"
  "
'
```

Commands intercepted by dry-run: `mkdir rm cp chmod ln tar curl npm pip
cargo go crontab sudo_run`.

To run a real command inside a dry-run block (e.g. create a fixture file):

```sh
with_dry_run "
  dry_run_real mkdir -p /tmp/fixture_$$
  npm install typescript     # recorded, not executed
  assert_file_exists /tmp/fixture_$$ \"fixture dir created for real\"
  dry_run_real rm -rf /tmp/fixture_$$
"
```

---

## What to test and how

### Testing a library function (`lib/all/*.sh`)

Source only that file. Stub any functions it calls that you don't want
to test. Test the behaviour directly.

```sh
# test/unit/platform/mylib_test.sh
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"
. "$SCRIPT_DIR/../../../lib/all/mylib.sh"

describe "my_function"

test "returns correct value for input X" '
  local _result
  _result=$(my_function "X")
  assert_eq "expected" "$_result" "X produces expected"
'

test "calls exit_with_error for empty input" '
  stub_exit_reset
  my_function ""
  assert_not_empty "$_stub_exit_error" "empty input rejected"
'

run_tests
```

### Testing an install module (`app/install/lib/all/install/module/*.sh`)

Source `module.sh` (for tracking primitives) and the specific module file.
Use `setup_target_paths` for realistic paths and `with_dry_run` for
destructive operations.

```sh
. "$SCRIPT_DIR/../../../app/install/lib/all/install/module.sh"
. "$SCRIPT_DIR/../../../app/install/lib/all/install/module/bin.sh"

_base=""
setup ' _base=$(mktemp -d); setup_target_paths "$_base" '
teardown ' teardown_target_paths "$_base"; rm -rf "$_base" '

test "bin_install copies files to bin path" '
  setup_type_name=bin
  local _src
  _src=$(mktemp -d)
  printf "#!/bin/sh\n" > "$_src/mytool"
  with_dry_run "
    bin_install \"\$_src\"
    assert_contains \"\$TARGET_APP_PLATFORM_BIN_PATH\" \"\$dry_run_log\" \
      \"bin path is destination\"
  "
  rm -rf "$_src"
'
```

### Testing a `.run` setup script

`.run` scripts are sourced at install time and use `TARGET_*` variables.
Set those variables explicitly, then source the script.

```sh
test "detect-secrets run installs venv" '
  TARGET_APP_PATH=/tmp/test_app_$$
  conf_dev_detect_secrets_venv="$TARGET_APP_PATH/python/env/detect_secrets"
  conf_dev_detect_secrets_python_artifact=detect-secrets
  with_dry_run "
    . \"\$SCRIPT_DIR/../../../app/dev/git/setup/all/scan.feature/\
setup/all/python-detect-secrets.feature/setup/all/999.install-detect-secrets.run\"
    assert_contains python \"\$dry_run_log\" \"python called\"
    assert_contains detect-secrets \"\$dry_run_log\" \"package installed\"
    assert_dry_run_contains \"\$conf_dev_detect_secrets_venv\" \"venv path used\"
  "
  rm -rf /tmp/test_app_$$
'
```

### Testing a built bin command

Built bin commands (`setup/all/bin/app-install` etc.) are complete scripts
with their own constants baked in. Test their logic by sourcing them directly
after setting the constants they expect, or by testing the library functions
they call individually (preferred — simpler and faster).

```sh
# Preferred: test the underlying library function
. "$SCRIPT_DIR/../../../app/install/lib/all/install/app.sh"

test "version suffix stripped from app name" '
  target_application_name="git@v1.2.3"
  # simulate what _app_setup_project does at the top
  target_application_version_requested="${target_application_name#*@}"
  target_application_name="${target_application_name%@*}"
  assert_eq "git" "$target_application_name" "name stripped"
  assert_eq "v1.2.3" "$target_application_version_requested" "version captured"
'
```

### Testing platform_is_supported in a setup script

```sh
test "script rejects wrong platform" '
  stub_exit_reset
  APP_PLATFORM_PLATFORM=Windows
  platform_is_supported "Linux FreeBSD Apple"
  assert_not_empty "$_stub_exit_error" "Windows rejected"
  assert_contains "Windows" "$_stub_exit_error" "platform named in error"
'
```

### Testing SYSTEM vs USER install behaviour

Use `id()` to stub the uid check without needing real privileges:

```sh
test "USER path used when install_user=USER" '
  install_user=USER
  HOME=/home/w
  APP_PLATFORM_ROOT=/
  target_application_name=git
  id() { case "$1" in -u) printf "1000";; esac; }
  _settings_application_defaults() { :; }
  _include_optional() { :; }
  mkdir() { :; }
  _settings_validate_install_user
  _settings_resolve_target_paths
  assert_contains "/home/w" "$TARGET_APP_PATH" "HOME-relative path"
  unset -f id mkdir
'
```

---

## Regression tests

When a bug is fixed, add a test that would have caught it. Name the test after
the bug so it is obvious what it guards against:

```sh
test "uninstall_type uses no leading underscore in function name (regression)" '
  # The bug: exec_call "_${type}_uninstall" instead of "${type}_uninstall"
  # caused every uninstall to silently do nothing.
  _bin_uninstall_called=""
  bin_uninstall() { _bin_uninstall_called="YES"; }
  mkdir -p "$TARGET_APP_PATH/type"
  printf "/usr/local/bin/tool\n" > "$TARGET_APP_PATH/type/bin"
  uninstall_type
  assert_eq "YES" "$_bin_uninstall_called" \
    "bin_uninstall called (no leading underscore)"
'
```

---

## Quick reference

```sh
# Run all tests
./test/run_tests.sh

# Run one file
./test/run_tests.sh -f test/unit/install/settings_test.sh

# Run with real commands (passthrough mode)
DRY_RUN_MODE=passthrough ./test/run_tests.sh

# Minimal test file template
#!/bin/sh
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../../lib/runner.sh"
. "$SCRIPT_DIR/../../lib/assert.sh"
. "$SCRIPT_DIR/../../lib/fixtures.sh"
. "$SCRIPT_DIR/../../../lib/all/mylib.sh"   # file under test

describe "my feature"

test "does X when given Y" '
  local _result
  _result=$(my_function "Y")
  assert_eq "X" "$_result" "Y produces X"
'

run_tests
```
