_notification_notify() {
  local _title=$1
  local _message=$2

  zenity --log_info --text="${APPLICATION_NAME} - ${APPLICATION_CMD} - $_title\n$_message"
}

