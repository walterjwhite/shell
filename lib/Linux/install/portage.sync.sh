_emerge_portage_sync() {
  [ -n "$emerge_bootstrap_install" ] && return 1

  emerge_sync_file=$APP_PLATFORM_ROOT/var/cache/.portage.sync.time
  _emerge_portage_synced && {
    log_debug "portage was already synced today"
    return
  }

  mkdir -p $(dirname $emerge_sync_file)

  _package_emerge_cmd $emerge_options --sync && {
    date +%s >"$emerge_sync_file"
  }
}

_emerge_portage_synced() {
  [ ! -e $emerge_sync_file ] && return 1

  local last_synced=$(head -1 $emerge_sync_file)
  local current_time=$(date +%s)

  [ -z "$last_synced" ] && return 1

  [ $(($current_time - $last_synced)) -le $emerge_portage_refresh_period ]
}
