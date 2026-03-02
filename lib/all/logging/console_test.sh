console_test_logging() {
  export conf_log_console=1
  call_test_function _console_log_to_console "1;31" "Test exit_with_error message with spaces"
  assert_equal "$(grep -c "Test exit_with_error message with spaces" "$TEST_TEMP_FILE")" "1" \
    "Should log message containing spaces correctly"

  (
    unset conf_log_console
    call_test_function _console_log_to_console "1;31" "This Should Be Invisible"
    assert_equal "$(grep -c "This Should Be Invisible" "$TEST_TEMP_FILE")" "0" \
      "Should NOT log anything when conf_log_console is unset"
  )

  call_test_function _console_colorize_text "1;32m" "Green text"

  local expected_ansi
  expected_ansi=$(printf '\033[1;32mGreen text\033[0m')

  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE")" "$expected_ansi" \
    "Should output correctly formatted ANSI color string"

  call_test_function _console_print_to_console "No newline"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE")" "No newline" \
    "Should print string without automatic newline"

  call_test_function _console_print_newline_to_console

  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE")" "" \
    "Should print just a newline (resulting in empty tail)"
}
