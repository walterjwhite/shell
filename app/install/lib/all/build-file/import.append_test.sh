_setup() {
  TEST_DIR=$(mktemp -d)

  export project_root="$TEST_DIR/project"
  export target_platform="linux"
  export output_package_file="$TEST_DIR/output.sh"

  export buildfile_imported_files=""

  mkdir -p "$project_root"
  touch "$buildfile_output_package_file"
}

_teardown() {
  rm -rf "$TEST_DIR"
  unset buildfile_imported_files
}

test_import_append_basic() {
  local src="$TEST_DIR/source.sh"
  local dest="$TEST_DIR/dest.sh"
  echo "content_a" >"$src"
  touch "$dest"

  _CALL_TEST_FUNCTION _import_append_file "$dest" "$src"

  assert_file_contains "$dest" "content_a" "File content should be appended"
  assert_equal "$buildfile_imported_files" "|$src|" "File should be added to tracking variable"
}












