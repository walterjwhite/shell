_notify() {
  if [ $# -ne 3 ]; then
    printf '3 args are required (title, body)\n'
    exit 1
  fi

  powershell -f $APP_LIBRARY_PATH/notifications.ps1 "$APPLICATION_NAME - $APPLICATION_CMD" $@
}
