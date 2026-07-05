#!/bin/sh


SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
. "$SCRIPT_DIR/../lib/runner.sh"
. "$SCRIPT_DIR/../lib/assert.sh"
. "$SCRIPT_DIR/../lib/fixtures.sh"
. "$SCRIPT_DIR/../lib/dry_run.sh"

. "$SCRIPT_DIR/../../app/install/lib/all/install/module.sh"
. "$SCRIPT_DIR/../../app/install/lib/all/install/module/bin.sh"
. "$SCRIPT_DIR/../../app/install/lib/all/install/module/files.sh"
. "$SCRIPT_DIR/../../app/install/lib/all/install/module/run.sh"
. "$SCRIPT_DIR/../../app/install/lib/all/install/metadata.sh"

_base=""
setup '
  _base=$(mktemp -d)
  setup_target_paths "$_base"
'
teardown '
  teardown_target_paths "$_base"
  rm -rf "$_base"
'

describe "bin_install: dry-run"

test "records mkdir and tar for bin path" '
  setup_type_name=bin
  local _src
  _src=$(mktemp -d)
  printf "#!/bin/sh\necho hi\n" > "$_src/mytool"
  with_dry_run "
    bin_install \"\$_src\"
    assert_contains mkdir \"\$dry_run_log\" \"mkdir recorded\"
    assert_contains \"\$TARGET_APP_PLATFORM_BIN_PATH\" \"\$dry_run_log\" \"bin path in commands\"
  "
  rm -rf "$_src"
'

describe "run_uninstall: tracked entry removal"

test "removes tracked file entries" '
  setup_type_name=run
  mkdir -p "$TARGET_APP_PATH/type"
  local _type_file="$TARGET_APP_PATH/type/run"
  printf '/usr/local/bin/mytool\n' > "$_type_file"
  with_dry_run "
    run_uninstall \"\$_type_file\"
    assert_contains rm \"\$dry_run_log\" \"rm recorded\"
    assert_contains /usr/local/bin/mytool \"\$dry_run_log\" \"file path in rm\"
  "
'

test "uses rm -rf for directory entries" '
  setup_type_name=run
  mkdir -p "$TARGET_APP_PATH/type"
  local _type_file="$TARGET_APP_PATH/type/run"
  printf '/opt/myapp/\n' > "$_type_file"
  with_dry_run "
    run_uninstall \"\$_type_file\"
    assert_contains rm -rf \"\$dry_run_log\" \"rm -rf for directory\"
  "
'

test "uses rm -f for file entries" '
  setup_type_name=run
  mkdir -p "$TARGET_APP_PATH/type"
  local _type_file="$TARGET_APP_PATH/type/run"
  printf '/usr/local/bin/tool\n' > "$_type_file"
  with_dry_run "
    run_uninstall \"\$_type_file\"
    assert_contains rm -f \"\$dry_run_log\" \"rm -f for file\"
  "
'

describe "metadata: TARGET_* not written to .metadata"

test ".metadata contains provenance but no TARGET variables" '
  DRY_RUN_MODE=passthrough
  mkdir -p "$TARGET_APP_PATH"
  git_target_application_url="git@git:/test/app"
  target_application_install_date="Mon Jan 01 00:00:00 2025 +0000"
  target_application_version="abc123"
  target_application_build_date="Mon Jan 01 00:00:00 2025 +0000"
  _metadata_write_app
  assert_file_exists "$TARGET_APP_PATH/.metadata" "metadata created"
  assert_file_contains "$TARGET_APP_PATH/.metadata" "APPLICATION_GIT_URL" "git url present"
  assert_file_contains "$TARGET_APP_PATH/.metadata" "APPLICATION_VERSION" "version present"
  assert_fail "grep -q TARGET_ \"$TARGET_APP_PATH/.metadata\"" "no TARGET_ vars in metadata"
  DRY_RUN_MODE=record
'

describe "_install_record_path: tracking"

test "records path into type tracking file" '
  setup_type_name=run
  stub_tracking_reset
  _install_record_path "/opt/myapp/bin/tool"
  assert_contains "/opt/myapp/bin/tool" "$_stub_type_tracking" "path tracked"
'

test "records directory with trailing slash" '
  setup_type_name=run
  stub_tracking_reset
  _install_record_dir "/opt/myapp"
  assert_contains "/opt/myapp/" "$_stub_type_tracking" "dir tracked with slash"
'

test "fails cleanly when setup_type_name unset" '
  stub_exit_reset
  unset setup_type_name
  _install_record_path "/some/path"
  assert_not_empty "$_stub_exit_error" "error triggered"
  assert_contains "setup_type_name" "$_stub_exit_error" "error names variable"
'

run_tests
