lib clipboard.sh
lib git/data.app.sh

cfg git

_videos_date() {
  date +%Y/%m/%d/%H.%M.%S
}

_video_fetch_metadata() {
  log_info "fetching metadata for: $videos_url"

  $conf_videos_youtube_download_cmd --print \
    "%(original_url)s|%(upload_date>%Y/%m/%d)s|%(duration>%H:%M:%S)s|%(title)s|%(uploader_id)s|%(uploader)s" \
    "$videos_url" | sed -e "s/$/|$_VIDEOSextract_audio|$video_profiles/" |
    while IFS= read -r video_metadata; do
      video_file=${_action}d/$(_videos_date)
      mkdir -p $(dirname $video_file)

      printf '%s\n' "$video_metadata" >$video_file
      _video_meta

      _videos_git $video_file
    done
}

_video_read_meta() {
  [ ! -e $video_file ] && return 1

  log_debug "reading video metadata from: $video_file"
  video_metadata=$(head -1 $video_file)
}

_video_meta() {
  videos_url=$(printf '%s' $video_metadata | cut -f1 -d'|')

  video_key=$(printf '%s' $videos_url | sed -e "s/^.*\=//")

  video_date=$(printf '%s' $video_metadata | cut -f2 -d'|')
  video_duration=$(printf '%s' $video_metadata | cut -f3 -d'|')
  video_title=$(printf '%s' $video_metadata | cut -f4 -d'|')
  video_uploader_id=$(printf '%s' $video_metadata | cut -f5 -d'|')
  video_uploader_name=$(printf '%s' $video_metadata | cut -f6 -d'|')

  log_info "$videos_url - $video_title @ $video_duration ($video_date:$video_uploader_id:$video_uploader_name)"
}

_videos_git() {
  _data_app_save "$_action - $video_key" "$@"
}

_videos_clipboard_get() {
  videos_url=$(_clipboard_get | sed -e 's/&.*$//')
}
