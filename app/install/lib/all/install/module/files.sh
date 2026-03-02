files_install() {
  _install_files $1/_ROOT_ $APP_PLATFORM_ROOT
  _install_files $1/_APPLICATION_ROOT_ "$APP_PLATFORM_LIBRARY_PATH/$target_application_name"
}

files_uninstall() {
  [ ! -e $1 ] && return

  rm -f $(cat $1)
  rm -f $1
}
