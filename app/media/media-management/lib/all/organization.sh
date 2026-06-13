#!/bin/sh

_organize_by_date() {
  for media_file in $(find $_STAGING_AREA -type f); do
    _organize_by_date_do
  done
}

_organize_by_date_do() {
  local media_date=$(_media_get_date "$media_file")

  [ -z "$media_date" ] && {
    log_warn "no date found for: $media_file"
    return 1
  }

  local year=$(printf '%s' "$media_date" | cut -d/ -f1)
  local decade_start=$(((year / 10) * 10 + 1))
  local decade_end=$((decade_start + 9))

  local date_based_dir="${_STAGING_AREA}/${decade_start}-${decade_end}/${media_date}"

  mkdir -p "$date_based_dir"

  local filename=$(basename "$media_file")
  local target_file="${date_based_dir}/${filename}"

  log_info "organizing $media_file -> $date_based_dir"
  mv "$media_file" "$target_file"
}

_media_get_date() {
  local media_file="$1"
  case "$media_file" in
  *.jpg | *.jpeg | *.png | *.cr2 | *.nef | *.arw)
    exiftool -DateTimeOriginal -d "%Y/%m.%B/%d" "$media_file" 2>/dev/null | grep "Date/Time Original" | cut -d: -f2- | tr -d ' '
    return
    ;;
  *.mp4 | *.mov | *.avi | *.mkv | *.mts | *.m2ts)
    exiftool -CreationDate -d "%Y/%m.%B/%d" "$media_file" 2>/dev/null | grep "Creation Date" | cut -d: -f2- | tr -d ' '
    return
    ;;
  esac
}

_remove_spaces() {
  local media_directory
  for media_directory in $(find $_STAGING_AREA -maxdepth 1 -type d -name '*[0-9]*' -name '*-*'); do
    find $media_directory -type f -name '* *' -exec replace-space {} \;
  done
}
