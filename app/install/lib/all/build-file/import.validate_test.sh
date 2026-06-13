test_validate_paths_exit_with_success() {
  local target="$TEST_DIR/found_file"
  touch "$target"

  _CALL_TEST_FUNCTION _import_validate_paths "$TEST_DIR"
  assert_success "should return 0 when find locates files"
}

test_validate_paths_failure() {
  local empty_dir="$TEST_DIR/empty"
  mkdir -p "$empty_dir"

  _CALL_TEST_FUNCTION _import_validate_paths "$empty_dir" 2>/dev/null
  assert_failure "Should return 1 when no files are found"
}
