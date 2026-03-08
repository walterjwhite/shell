lib git/github.sh
lib provider.sh

readonly BROWSER_CMD=firefox

browser_new_instance() {
  log_info "copying profile to $instance_directory"

  mkdir -p $instance_directory

  tar cp - -C ~/ .mozilla | tar xp - -C $instance_directory

  log_info "updating conf to use new instance dir"
  find $instance_directory -type f ! -name '*.sqlite' -exec $GNU_SED -i "s|$HOME|$instance_directory|g" {} +

  _QUERY="SELECT url,ROUND(last_visit_date / 1000000) FROM moz_places WHERE VISIT_COUNT > 0 ORDER BY last_visit_date DESC"

  firefox_install_extensions
}

_history_file() {
  _SQLITE_DATABASE=$(find $instance_directory -type f -name 'places.sqlite')
  [ $_SQLITE_DATABASE ] || exit_with_error "error locating places database"
}

_browser_remote_debug() {
  if [ $_WEB_BROWSER_REMOTElog_debug -gt 0 ]; then
    _browser_add_args --remote-debugging-port=$web_browser_remote_debug
  else
    _browser_add_args --remote-debugging-port
  fi

  [ "$_WEB_BROWSER_HEADLESS" ] && _browser_add_args --headless
}

_browser_private_window() {
  _browser_add_args --private-window
  _browser_add_args "--new-instance"
}

browser_http_proxy() {
  http_proxy=$web_browser_http_proxy
  https_proxy=$web_browser_http_proxy

  _browser_add_args "--new-instance"
}

_browser_socks_proxy() {
  user_pref_file=$(find $instance_directory -type f -name prefs.js -print -quit)

  file_require $user_pref_file 'Firefox user pref.js'

  socks_host="${_WEB_BROWSER_SOCKS_PROXY%%:*}"
  socks_port="${_WEB_BROWSER_SOCKS_PROXY#*:}"

  printf 'user_pref("network.proxy.socks", "%s");\n' "$socks_host" >>$user_pref_file
  printf 'user_pref("network.proxy.socks_port", %s);\n' "$socks_port" >>$user_pref_file
  printf 'user_pref("network.proxy.type", 1);\n' >>$user_pref_file

  _browser_add_args "--new-instance"
}

firefox_install_extensions() {
  _FIREFOX_EXTENSION_PATH=$(find $instance_directory/.mozilla/firefox -mindepth 1 -maxdepth 1 -type d -print -quit)/extensions
  rm -rf $_FIREFOX_EXTENSION_PATH && mkdir -p $_FIREFOX_EXTENSION_PATH

  log_info "installing extensions to: $_FIREFOX_EXTENSION_PATH"

  provider_name
  for provider_name in $(cat $instance_directory/.mozilla/extensions 2>/dev/null); do
    firefox_install_extension $provider_name
  done
}

firefox_install_extension() {
  case $1 in
  browserpass@maximbaz.com)
    firefox_extension_load $1 https://addons.mozilla.org/firefox/downloads/file/4187654/browserpass_ce-3.8.0.xpi
    ;;
  firefox@ghostery.com)
    firefox_extension_load $1 https://addons.mozilla.org/firefox/downloads/file/4207768/ghostery-8.12.5.xpi
    ;;
  passff@invicem.pro)
    firefox_extension_load $1 https://addons.mozilla.org/firefox/downloads/file/4202971/passff-1.16.xpi
    ;;
  uBlock0@raymondhill.net)
    firefox_extension_load $1 https://addons.mozilla.org/firefox/downloads/file/4198829/ublock_origin-1.57.2.xpi
    ;;
  jid1-ZAdIEUB7XOzOJw@jetpack)
    firefox_extension_load $1 https://addons.mozilla.org/firefox/downloads/file/4205925/duckduckgo_for_firefox-2023.12.6.xpi
    ;;
  *)
    log_warn "unsupported extension: $1"
    continue
    ;;
  esac
}

firefox_extension_load() {
  _download_fetch $2

  log_detail "copying $download_file -> $_FIREFOX_EXTENSION_PATH/$1.xpi"
  cp $download_file $_FIREFOX_EXTENSION_PATH/$1.xpi
}
