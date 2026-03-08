_vizio_set_volume() {
  local volume="$1"
  validation_request "$volume" "volume <0-100>"

  if [ "$VOL" -lt 0 ] || [ "$VOL" -gt 100 ]; then
    exit_with_error "volume must be 0–100"
  fi

  _vizio_api PUT /menu_native/dynamic/tv_settings/audio/volume \
    "{\"REQUEST\":\"MODIFY\",\"VALUE\":${VOL},\"HASHVAL\":0}" | _vizio_api_success && {
    log_detail "volume set to $vol"
    return 0
  }

  log_warn "unable to set volume"
  return 1
}
