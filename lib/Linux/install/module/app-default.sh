app_default_bootstrap() {
  :
}

app_default_install() {
  local _desktop=$1
  local _file_type=$2
  if [ -n "$USER" ]; then
    sudo_user="$USER" sudo_run xdg-mime default "$_desktop.desktop" "$_file_type"
    local _result=$?
    unset _desktop _file_type
    return $_result
  fi

  xdg-mime default "$_desktop.desktop" "$_file_type"
  local _result=$?
  unset _desktop _file_type
  return $_result
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
