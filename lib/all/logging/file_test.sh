file_test_logging() {
  log_set_logfile "$TEST_TEMP_FILE"

  _file_log_to_file "TEST" "test log message"
  assert_equal "$(grep -c "test log message" "$log_logfile")" "1" "Message should be logged to file"
  _reset_test_logs

  _file_log_to_file "TEST" "format test"
  assert_equal "$(tail -n 1 "$log_logfile" | $GNU_GREP -Pc '^[0-9]{4}/[0-9]{2}/[0-9]{2} [0-9]{2}:[0-9]{2}:[0-9]{2} TEST format test$')" "1" "Log format should match expected pattern"
  _reset_test_logs

  local old_logfile=$log_logfile
  local new_logfile="/tmp/new_test.log"
  log_set_logfile "$new_logfile"
  _file_log_to_file "TEST" "new file test"
  assert_equal "$(grep -c "new file test" "$new_logfile")" "1" "Should log to new file"
  assert_equal "$(grep -c "new file test" "$old_logfile")" "0" "old file should not have logs"
  _reset_test_logs

  rm -f $new_logfile
}
