#!/bin/sh

lib ./videos-podcast.sh

_video_download() {
  _video_read_meta
  _video_meta

  is_playlist=$(printf '%s' "$videos_url" | grep -c list=)

  _options=""
  [ -z "$interactive" ] && _options="--no-color -q"

  if [ -n "$extract_audio" ]; then
    log_warn "configuring audio extraction"
    _options="$_options $conf_videos_youtube_audio_download_options"
  else
    _options="$_options $conf_videos_youtube_video_download_options"
  fi

  if [ $is_playlist -eq 1 ]; then
    log_warn "is playlist"
    _options="$_options --restrict-filenames -o $conf_videos_download_path/downloaded/%(playlist)s/%(playlist_index)s-%(title)s-$video_key.%(ext)s"
  elif [ -n "$podcast_channel_title" ]; then
    local sanitized_channel=$(printf '%s' "$podcast_channel_title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
    local sanitized_title=$(printf '%s' "$podcast_title" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/--*/-/g' | sed 's/^-//;s/-$//')
    _options="$_options --restrict-filenames -o $conf_videos_download_path/downloaded/${sanitized_channel}-${sanitized_title}-$video_key.%(ext)s"
  else
    _options="$_options --restrict-filenames -o $conf_videos_download_path/downloaded/%(title)s-$video_key.%(ext)s"
  fi

  _videos_download_setup_proxy

  log_info "downloading $videos_url - $video_title @ $video_duration"
  log_debug "video metadata: $video_date:$video_uploader_id:$video_uploader_name"

  $conf_videos_youtube_download_cmd $_options "$videos_url" || _video_download_error

  if [ -n "$extract_audio" ]; then
    log_warn "extracting audio"
    _video_download_extract_audio
    return
  fi

  _video_download_success
  _video_download_convert
}

_videos_download_setup_proxy() {
  [ -n "$http_proxy" ] && {
    _options="$_options --proxy $http_proxy"
    return
  }

  [ -n "$_VIDEOS_PROXY" ] && {
    _options="$_options --proxy $_VIDEOS_PROXY"
    return
  }

  return 1
}

_video_download_error() {
  _video_download_git error "download error"
  exit_with_error "error downloading video - $video_key" $_status
}

_video_download_extract_audio() {
  _video_download_git downloaded "download / extract audio"
}

_video_download_success() {
  _video_download_git downloaded "download"
  log_info "successfully downloaded $videos_url - $video_title @ $video_duration"
}

_video_download_git() {
  local _video_target=$1/$(_videos_date)
  mkdir -p $(dirname $_video_target)

  git mv $video_file $_video_target || {
    git add $video_file && git mv $video_file $_video_target || exit_with_error "error moving $video_file -> $_video_target"
  }

  _videos_git $video_file $_video_target
  unset _video_target _DOWNLOAD_ARGS
}

_video_download_convert() {
  [ -z "$video_profiles" ] && return 1

  video_media_file=$(find $conf_videos_download_path -type f ! -name '.part' -name "*$video_key*")
  validation_require "$video_media_file" video_media_file

  for video_profile in $video_profiles; do
    log_info "converting video with $video_profile"

    local video_profile_name=$(printf $video_profile | tr '[:lower:]' '[:upper:]')

    local profile_video_format=$(set | grep "^conf_videos_profile_${video_profile_name}_VIDEO_FORMAT=.*" | sed -e 's/^.*\=//')
    local profile_options=$(set | grep "^conf_videos_profile_${video_profile_name}_options=.*" | sed -e 's/^.*\=//')

    ffmpeg -i "$video_media_file" $profile_options ${video_media_file}-$video_profile.$profile_video_format
  done
}
