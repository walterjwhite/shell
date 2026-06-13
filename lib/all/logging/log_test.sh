log_test_functions() {
  conf_log_level=1
  call_test_function log_debug "debug message"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE" | grep -c "debug message")" "1" \
    "debug message should be logged at log_debug level"

  call_test_function log_info "info message"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE" | grep -c "info message")" "1" \
    "info message should be logged at info level"

  call_test_function log_warn "warning message"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE" | grep -c "warning message")" "1" \
    "warning message should be logged at warning level"

  call_test_function log_detail "detail message"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE" | grep -c "detail message")" "1" \
    "detail message should be logged at log_detail level"
}

log_test_background_notifications() {
  optn_install_background_notification_method="echo"
  backgrounded=1

  call_test_function log_info "test notification"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE" | grep -c "test notification")" "1" \
    "Should log message to console"
}
