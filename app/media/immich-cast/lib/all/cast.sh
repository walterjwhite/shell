cast_slideshow() {
  log_detail "starting slideshow on $chromecast_device..."
  _vizio_do_on
  sleep 15

  go-chromecast -a "$chromecast_device" slideshow $(find "$conf_immich_memories_downloads" -type f \( -name '*.jpg' -or -name '*.mp4' \))
}

_stop_casting() {
  log_detail "$1"
  go-chromecast -a "$chromecast_device" stop 2>/dev/null || true

  _vizio_do_off
}
