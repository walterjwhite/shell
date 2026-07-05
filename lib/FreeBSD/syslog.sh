_syslog_syslog() {
  local _message=$1

  logger -i -t "${APPLICATION_NAME}.${APPLICATION_CMD}" "$_message"
}
