provider_path=~/.config/mac/screensaver

_configuration_mac_screensaver_restore() {
  if [ ! -e $APP_DATA_PATH/$provider_name/screensaver ]; then
    return
  fi

  . $APP_DATA_PATH/$provider_name/screensaver

  _SCREENSAVER_NAME="tell application \"System Events\" to set current screen saver to screen saver \"$conf_mac_screensaver_name\""
  _SCREENSAVER_TIMEOUT="tell application \"System Events\" to set delay interval of screen saver preferences to $conf_mac_screensaver_timeout -- Number In Seconds"

  osascript -e "$_SCREENSAVER_NAME" -e "$_SCREENSAVER_TIMEOUT"
}
