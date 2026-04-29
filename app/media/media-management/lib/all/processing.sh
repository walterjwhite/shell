#!/bin/sh

_media_process_staging_all() {
  _media_process_staging output -v
  _media_process_staging raw
}

_media_process_staging() {
  local media_directory
  for media_directory in $(find $_STAGING_AREA -maxdepth 1 -type d -name '*[0-9]*' -name '*-*'); do
    for f in $(find $media_directory -type f | grep $2 CR2); do
      _process_event_file $1
    done
  done
}

_process_event_file() {
  local _target_volume=$1

  local _event_file=$(printf '%s' $f | sed -e "s/^.*staging\///")
  local _event_directory=$(dirname $_event_file | sed -e "s/^\///" -e "s/converted\///")

  local _event_target_directory=${conf_media_mountpoint}/${_target_volume}/by-time/walter/${_event_directory}

  log_info "moving $f -> $_event_target_directory"

  chown $conf_media_user:$conf_media_user $f

  sudo_user=$conf_media_user sudo_run mkdir -p $_event_target_directory
  mv $f $_event_target_directory
}

_has_media() {
  local media_directory
  for media_directory in $(find $_STAGING_AREA -maxdepth 1 -type d -name '*[0-9]*' -name '*-*'); do
    [ $(find $media_directory -type f | wc -l) -eq 0 ] && return 1
  done

  return 0
}

_cleanup_staging() {
  local media_directory
  for media_directory in $(find $_STAGING_AREA -maxdepth 1 -type d -name '*[0-9]*' -name '*-*'); do
    if [ $(find $media_directory -type f | wc -l) -eq 0 ]; then
      log_info "removing empty directories: $media_directory"
      rm -rf $media_directory
    else
      log_warn "staging area is not empty, not cleaning up: $media_directory"
    fi
  done
}
