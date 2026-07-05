lib git/data.app.sh

_export_history() {
  [ -z "$_SQLITE_DATABASE" ] && {
    exec_call _history_file || return 1

    [ -z "$_SQLITE_DATABASE" ] && return 2
  }

  [ -n "$_ORIGINAL_HOME" ] && HOME=$_ORIGINAL_HOME

  _HISTORY_FILE=$APP_DATA_PATH/history/$conf_web_browser_browser-$APP_CONTEXT/$(date "+%Y%m%d%H%M%S")
  log_info "$APP_CONTEXT browser history >$_HISTORY_FILE"

  mkdir -p $(dirname $_HISTORY_FILE)
  sqlite3 -csv $_SQLITE_DATABASE "$_QUERY" | tr -d '"' >$_HISTORY_FILE 2>&1

  if [ $(wc -l $_HISTORY_FILE | awk {'print$1'}) -gt 0 ]; then
    _data_app_save "$APP_CONTEXT" $_HISTORY_FILE
  else
    log_warn "pruning empty history: $_HISTORY_FILE"
    rm -f $_HISTORY_FILE
  fi
}

_save_history() {
  [ "$conf_web_browser_save_browser_history_with_proxy" -eq 0 ] && {
    log_warn "not saving browser history"
    unset _SQLITE_DATABASE
    return
  }

  log_info "saving browser history"
}
