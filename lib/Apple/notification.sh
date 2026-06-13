_notification_notify() {
  local _title=$1
  local _message=$2

  osascript -e "display notification \"$_message\" with title \"$APPLICATION_NAME - $APPLICATION_CMD - $_title\""
}
