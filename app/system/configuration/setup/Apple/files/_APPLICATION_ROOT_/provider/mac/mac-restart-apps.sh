provider_path=~/.config/mac/restart-apps

_configuration_mac_restart_apps_restore() {
  if [ ! -e $APP_DATA_PATH/$provider_name/restart-apps ]; then
    return
  fi

  local restart_app
  while read restart_app; do
    pkill -1 -lf $restart_app
  done <$APP_DATA_PATH/$provider_name/restart-apps
}
