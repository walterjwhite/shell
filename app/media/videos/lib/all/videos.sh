lib clipboard.sh
lib git/data.app.sh

cfg git
cfg git

_videos_previously_downloaded() {
  [ -n "$force" ] && return 1

  grep "$videos_url" queued downloaded watched -rqm1 2>/dev/null
}

_videos_date() {
  date +%Y/%m/%d/%H.%M.%S
}

_video_fetch_metadata() {
  log_info "fetching metadata for: $videos_url"

  $conf_videos_youtube_download_cmd --replace-in-metadata "title" "\|" "-" \
    --print \
    "%(original_url)s|%(upload_date>%Y/%m/%d)s|%(duration>%H:%M:%S)s|%(title)s|%(uploader_id)s|%(uploader)s" \
    "$videos_url" | sed -e "s/$/|$videos_tags|$extract_audio|$video_profiles/" |
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

  case $video_key in
  *awsEpisodeId=*)
    video_key=$(printf '%s' $video_key | grep -Po 'awEpisodeId=[A-Za-z0-9\-]+' | cut -f2 -d=)
    ;;
  *)
    video_key=$(printf '%s' $videos_url | sed -e "s/^.*\=//")
    ;;
  esac

  [ -z "$video_key" ] && {
    video_key=$(printf '%s' $videos_url | sed 's/\.[^.]\{2,4\}$//')
  }

  video_date=$(printf '%s' $video_metadata | cut -f2 -d'|')
  video_duration=$(printf '%s' $video_metadata | cut -f3 -d'|')
  video_title=$(printf '%s' $video_metadata | cut -f4 -d'|')
  video_uploader_id=$(printf '%s' $video_metadata | cut -f5 -d'|')
  video_uploader_name=$(printf '%s' $video_metadata | cut -f6 -d'|')

  video_tags=$(printf '%s' $video_metadata | cut -f7 -d'|')
  extract_audio=$(printf '%s' $video_metadata | cut -f8 -d'|')
  video_profiles=$(printf '%s' $video_metadata | cut -f9 -d'|')

  video_is_protected=$(printf '%s' $video_metadata | cut -f10 -d'|')

  video_last_position=$(printf '%s' $video_metadata | cut -f11 -d'|')
}

_videos_git() {
  _data_app_save "$_action - $video_key" "$@"
}

_videos_clipboard_get() {
  videos_url=$(_clipboard_get | sed -e 's/&.*$//')
}
