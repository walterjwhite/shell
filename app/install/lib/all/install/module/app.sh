app_install() {
  _install_filter_file_callback $1 _app_install_do
}

_app_install_do() {
  [ -z "$APP_INSTALL_DEPENDENCY" ] && {
    readonly APP_INSTALL_DEPENDENCY=1
    export APP_INSTALL_DEPENDENCY
  }

  app-install $1
}

app_uninstall() {
  _install_uninstall_filter_file_callback $1 app_uninstall_do
}

app_uninstall_do() {
  app-uninstall $1
}

app_is_installed() {
  [ -e $LIBRARY_PATH/$1/.metadata ]
}

app_is_latest() {
  :
}
