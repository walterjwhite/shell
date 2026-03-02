provider_path=/opt/homebrew
provider_path_is_dir=1

_configuration_homebrew_restore() {
  if [ ! -e $APP_DATA_PATH/$provider_name/homebrew ]; then
    return
  fi

  brew install $(cat $APP_DATA_PATH/$provider_name/homebrew)

  return 0
}

_configuration_homebrew_backup() {
  rm -f $APP_DATA_PATH/$provider_name/homebrew
  brew bundle dump --file=$APP_DATA_PATH/$provider_name/homebrew

  return 0
}
