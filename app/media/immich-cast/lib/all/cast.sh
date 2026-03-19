cast_slideshow() {
  log_detail "starting slideshow on $conf_immich_cast_chromecast_device..."
  _vizio_do_on
  sleep 15

  go-chromecast -a "$conf_immich_cast_chromecast_device" slideshow $(find "$conf_immich_memories_downloads" -type f \( -name '*.jpg' -or -name '*.mp4' \))

  if [ -z "$cast_already_deferred_cleanup" ]; then
    exit_defer _stop_casting "stopping slideshow..."
    cast_already_deferred_cleanup=1
  fi
}

_stop_casting() {
  log_detail "$1"
  go-chromecast -a "$conf_immich_cast_chromecast_device" stop 2>/dev/null || true

  _vizio_do_off
}
