level_test_levels() {
  (
    conf_log_level=3
    call_test_function log_debug "this log_debug message should not appear"
  )
  assert_equal "$(grep -c "should not appear" "$TEST_TEMP_FILE")" "0" \
    "Messages below log level (Info/Debug) should not appear"

  (
    conf_log_level=1
    call_test_function log_debug "this log_debug message should appear"
  )
  assert_equal "$(grep -c "should appear" "$TEST_TEMP_FILE")" "1" \
    "Messages at log level Debug should appear"

  (
    conf_log_level=3
    call_test_function log_detail "this log_detail message should not appear"
  )
  assert_equal "$(grep -c "should not appear" "$TEST_TEMP_FILE")" "0" \
    "Messages below log level (Info/Debug) should not appear"

  (
    conf_log_level=3
    call_test_function log_info "this log_detail message should not appear"
  )
  assert_equal "$(grep -c "should not appear" "$TEST_TEMP_FILE")" "0" \
    "Messages below log level (Info/Debug) should not appear"

  (
    conf_log_level=3
    call_test_function log_warn "this warning should appear"
  )
  assert_equal "$(grep -c "should appear" "$TEST_TEMP_FILE")" "1" \
    "Messages at or above log level (Warn) should appear"
}
