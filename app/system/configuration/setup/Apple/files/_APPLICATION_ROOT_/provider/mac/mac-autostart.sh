provider_path=~/.config/mac/autostart

_configuration_mac_autostart_restore() {
  if [ ! -e $APP_DATA_PATH/$provider_name/autostart ]; then
    return
  fi

  local autostart_app
  while read autostart_app; do
    osascript -e "tell application \"$autostart_app\" to activate"
  done <$APP_DATA_PATH/$provider_name/autostart
}
