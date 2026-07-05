#!/bin/sh


test_imports_main_loop() {
  local type="lib"
  local source_file="$TEST_DIR/source_defs.sh"

  echo "lib import1" >"$source_file"

  touch "$buildfile_output_package_file"

  _import_process_single() {
    local _t_type=$1
    local _t_target=$2
    local _t_ref=$3

    echo "# processed $_t_ref" >>"$_t_target"

    if [ "$_t_ref" = "import1" ]; then
      echo "lib import2" >>"$_t_target"
    fi
    unset _t_type _t_target _t_ref
  }

  _CALL_TEST_FUNCTION _imports "$type" "$source_file" "default_lib"

  assert_file_contains "$buildfile_output_package_file" "# processed default_lib" "Should process default imports"

  assert_file_contains "$buildfile_output_package_file" "# processed import1" "Should process source imports"

  assert_file_contains "$buildfile_output_package_file" "# processed import2" "Should process nested recursive imports"

  if grep -q "^lib import2" "$buildfile_output_package_file"; then
    echo "FAIL: Import directives should be removed from target file"
    return 1
  fi
}
