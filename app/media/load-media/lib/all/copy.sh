_load_media_prepare_target() {
  mkdir -p "$conf_load_media_mount_point/$conf_load_media_target_path"

  _LOAD_MEDIA_SOURCE_DIRECTORY=$(_file_readlink "$_LOAD_MEDIA_SOURCE_DIRECTORY")
  _TARGET_DIRECTORY_NAME=$(basename "$_LOAD_MEDIA_SOURCE_DIRECTORY")
  if [ -e "$conf_load_media_mount_point/$conf_load_media_target_path/$_TARGET_DIRECTORY_NAME" ]; then
    _stdin_continue_if "Delete existing target?" "Y/n" || exit_with_error "$conf_load_media_mount_point/$conf_load_media_target_path/$_TARGET_DIRECTORY_NAME already exists"

    rm -rf "$conf_load_media_mount_point/$conf_load_media_target_path/$_TARGET_DIRECTORY_NAME"
  fi
}

_load_media_copy() {
  log_info "copying $_LOAD_MEDIA_SOURCE_DIRECTORY -> $conf_load_media_target_path"

  local file_to_copy
  for file_to_copy in $(find "$load_media_source_directory" -type f ! -name '*.secrets' ! -path '*/.archived/*'); do
    local target=$(printf '%s' "$file_to_copy" | sed -e "s|^$load_media_source_directory||")
    local target_directory=$(dirname "$target")

    local extension=$(_load_media_extension "$file_to_copy")

    mkdir -p "$conf_load_media_mount_point/$conf_load_media_target_path/$_TARGET_DIRECTORY_NAME/$target_directory"
    cp -R "$file_to_copy" "$conf_load_media_mount_point/$conf_load_media_target_path/$_TARGET_DIRECTORY_NAME/$target$extension"
  done
}

_load_media_extension() {
  if [ $(printf '%s' "$1" | $GNU_GREP -Pc '\.[\w]{3,4}$') -gt 0 ]; then
    log_debug "file $1, already has an extension"
    return
  fi

  local type=$(file $1 | cut -f2 -d':' | cut -f1 -d',' | sed -e 's/^ //')
  case "$type" in
  "ASCII text" | "UTF-8 text")
    printf '.txt'
    ;;
  *)
    log_warn "unknown type: $type"
    ;;
  esac
}
