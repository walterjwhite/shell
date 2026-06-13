app_default_bootstrap() {
  :
}

app_default_install() {
  local _app_desktop=$1
  local _mime_type=$2

  if [ -n "$USER" ]; then
    sudo_user="$USER" sudo_run xdg-mime default "$_app_desktop.desktop" "$_mime_type"
    return $?
  fi

  xdg-mime default "$_app_desktop.desktop" "$_mime_type"
}

app_default_uninstall() {
  :
}

app_default_is_installed() {
  :
}

app_default_enabled() {
  return 0
}
