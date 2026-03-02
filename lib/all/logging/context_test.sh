context_test_logging() {

  local initial_log_context=$logging_context
  [ -n "$initial_log_context" ] && initial_log_context="$initial_log_context:"

  log_add_context "TEST_CONTEXT"
  assert_equal "$logging_context" "${initial_log_context}TEST_CONTEXT" "context should match TEST_CONTEXT"

  call_test_function log_info "test message"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE" | _file_sanitize_input)" "${initial_log_context}TEST_CONTEXT - test message" "should include context"

  log_add_context "2"
  assert_equal "$logging_context" "${initial_log_context}TEST_CONTEXT:2" "context should match TEST_CONTEXT:2"

  call_test_function log_info "test message"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE" | _file_sanitize_input)" "${initial_log_context}TEST_CONTEXT:2 - test message" "should include context"

  log_add_context "3"
  assert_equal "$logging_context" "${initial_log_context}TEST_CONTEXT:2:3" "context should match TEST_CONTEXT:2:3"

  call_test_function log_info "test message"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE" | _file_sanitize_input)" "${initial_log_context}TEST_CONTEXT:2:3 - test message" "should include context"

  log_remove_context
  assert_equal "$logging_context" "${initial_log_context}TEST_CONTEXT:2" "context should match TEST_CONTEXT:2"

  log_remove_context
  assert_equal "$logging_context" "${initial_log_context}TEST_CONTEXT" "context should match TEST_CONTEXT"

  log_remove_context
  initial_log_context="${initial_log_context%:}"
  assert_equal "$logging_context" "${initial_log_context}" "context should be empty"

  call_test_function log_info "test message without context"
  assert_equal "$(tail -n 1 "$TEST_TEMP_FILE" | _file_sanitize_input)" "${initial_log_context} - test message without context" "Should not include context after removal"
}
