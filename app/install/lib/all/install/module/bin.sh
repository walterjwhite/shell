bin_install() {
  mkdir -p $APP_PLATFORM_BIN_PATH
  _install_files $1 $APP_PLATFORM_BIN_PATH
}

bin_uninstall() {
  [ ! -e $1 ] && return

  rm -f $(cat $1)
  rm -f $1
}

bin_is_installed() {
  :
}

bin_is_latest() {
  :
}
