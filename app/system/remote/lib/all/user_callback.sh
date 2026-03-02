user_callback() {
  validation_require "$_OPTN_REMOTE_USER_CALLBACK_CMD" _OPTN_REMOTE_USER_CALLBACK_CMD
  validation_require "$_OPTN_REMOTE_USER_CALLBACK_TIMEOUT" _OPTN_REMOTE_USER_CALLBACK_TIMEOUT

  log_info "running $_OPTN_REMOTE_USER_CALLBACK_CMD ($@) with timeout: $_OPTN_REMOTE_USER_CALLBACK_TIMEOUT"
  timeout $_OPTN_REMOTE_USER_CALLBACK_TIMEOUT $_OPTN_REMOTE_USER_CALLBACK_CMD "$@"

  local status=$?

  log_info "running $_OPTN_REMOTE_USER_CALLBACK_CMD ($@) with timeout: $_OPTN_REMOTE_USER_CALLBACK_TIMEOUT -> $status"
  return $status
}
