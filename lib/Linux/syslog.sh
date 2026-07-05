_syslog_syslog() {
  logger -i -t "$APPLICATION_NAME.$APPLICATION_CMD" "$1"
}
