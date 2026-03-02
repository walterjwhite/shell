help_install() {
  _install_files $1 "$APP_PLATFORM_LIBRARY_PATH/$target_application_name/help"
}

help_uninstall() {
  [ ! -e $1 ] && return

  rm -f $(cat $1)
  rm -f $1
}
