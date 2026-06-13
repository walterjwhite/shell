test_resolve_root_imports() {
  local type="lib"
  local ref="utils.sh"
  local expected_path="$project_root/$type/$target_platform/$ref"

  mkdir -p "$(dirname "$expected_path")"
  echo "root_lib_content" >"$expected_path"

  MOCK_LOG="$TEST_DIR/mock_log"
  _import_append_file() { echo "$2" >>"$MOCK_LOG"; }

  _CALL_TEST_FUNCTION _import_process_single "$type" "$buildfile_output_package_file" "$ref"

  assert_file_contains "$MOCK_LOG" "$expected_path" "Should resolve root path and find file"
}

test_resolve_relative_imports() {

  local type="lib"
  local ref="./local.sh"

  cd "$TEST_DIR" || exit 1

  local expected_path="$type/$target_platform/local.sh"
  mkdir -p "$(dirname "$expected_path")"
  touch "$expected_path"

  MOCK_LOG="$TEST_DIR/mock_log"
  _import_append_file() { echo "$2" >>"$MOCK_LOG"; }

  _CALL_TEST_FUNCTION _import_process_single "$type" "$buildfile_output_package_file" "$ref"

  assert_file_contains "$MOCK_LOG" "$expected_path" "Should resolve relative path"
}

test_resolve_feature_imports() {

  local type="lib"
  local feature_name="login.feature"
  local target="./features/$feature_name/linux/build.sh"
  local ref="feature:utils.sh"

  cd "$TEST_DIR" || exit 1
  mkdir -p "features/$feature_name/$type/$target_platform"
  local expected_path="./features/$feature_name/$type/$target_platform/utils.sh"
  touch "$expected_path"

  MOCK_LOG="$TEST_DIR/mock_log"
  _import_append_file() { echo "$2" >>"$MOCK_LOG"; }


  _CALL_TEST_FUNCTION _import_process_single "$type" "$target" "$ref"

  assert_file_contains "$MOCK_LOG" "$expected_path" "Should resolve feature: path relative to target feature dir"
}
