files_install() {
  _install_files $1/_ROOT_ $APP_PLATFORM_ROOT
  _install_files $1/_APPLICATION_ROOT_ "$APP_PLATFORM_LIBRARY_PATH/$target_application_name"

  return 0
}

files_uninstall() {
  [ ! -e $1 ] && return 0

  rm -f $(cat $1)
  rm -f $1
}

files_is_installed() {
  :
}

files_is_latest() {
  :
}
