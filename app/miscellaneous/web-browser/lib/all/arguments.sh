lib provider.sh

_browser_add_args() {
  browser_args="$browser_args $*"
}

_web_browser_cleanup() {
  _export_history

  log_warn "removing $instance_directory"

  rm -rf $instance_directory
}

web_browser_launch() {
  if [ -n "$_REMOTEdebug" ]; then
    $_BROWSER_CMD $browser_args 2>&1 | $GNU_GREP -m 1 --line-buffered -Po "ws://127.0.0.1:[\d]{3,6}/devtools/browser/[a-z\d]{8}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{4}-[a-z\d]{12}" \
      >>$instance_directory/remote
  else
    $_BROWSER_CMD $browser_args >/dev/null 2>&1
  fi

  wait
}

_browser_configure() {
  instance_directory=$(_mktemp_options=d _mktemp_mktemp)
  log_warn "using $instance_directory"

  exit_defer _web_browser_cleanup
  exit_defer _browser_cleanup

  _provider_load $conf_web_browser_browser

  _ORIGINAL_HOME=$HOME

  browser_new_instance

  [ ! -e $instance_directory/.gnupg ] && ln -s $HOME/.gnupg $instance_directory/.gnupg
  [ ! -e $instance_directory/.password-store ] && ln -s $HOME/.password-store $instance_directory/.password-store

  HOME=$instance_directory

  [ -n "$_REMOTEdebug" ] && _browser_remote_debug
  [ -n "$_NEW_PRIVATE_WINDOW" ] && _browser_private_window
  [ -n "$_http_proxy" ] && browser_http_proxy && _save_history
  [ -n "$_SOCKS_PROXY" ] && _browser_socks_proxy && _save_history
}

_browser_cleanup() {
  :
}
