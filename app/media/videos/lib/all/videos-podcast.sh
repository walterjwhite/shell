#!/bin/sh

_videos_download_podcasts() {
  [ -z "$conf_videos_podcasts" ] && {
    log_info "no podcasts configured"
    return 0
  }

  log_info "downloading podcasts"

  for podcast_url in $conf_videos_podcasts; do
    _videos_download_podcast "$podcast_url"
  done
}

_videos_download_podcast() {
  local podcast_url=$1
  local podcast_name=$(_videos_get_podcast_name "$podcast_url")

  log_info "processing podcast: $podcast_name"

  local podcast_feed=$(_videos_fetch_podcast_feed "$podcast_url")

  if [ -z "$podcast_feed" ]; then
    log_warn "failed to fetch podcast feed: $podcast_url"
    return 1
  fi

  printf '%s\n' "$podcast_feed" | while IFS= read -r episode_url; do
    [ -n "$episode_url" ] && _videos_download_podcast_episode "$episode_url" "$podcast_name"
  done
}

_videos_get_podcast_name() {
  local podcast_url=$1

  case "$podcast_url" in
  *npr.org*)
    printf '%s\n' "$podcast_url" | sed -e 's|.*/\([^/]*\)$|\1|'
    ;;
  *hiddenbrain.org*)
    printf '%s\n' "$podcast_url" | sed -e 's|.*/\([^/]*\)$|\1|'
    ;;
  *)
    printf '%s\n' "$podcast_url" | sed -e 's|https://\([^/]*\).*|\1|'
    ;;
  esac
}

_videos_fetch_podcast_feed() {
  local podcast_url=$1
  curl -s "$podcast_url" 2>/dev/null
}

_videos_download_podcast_episode() {
  local episode_url=$1
  local podcast_name=$2
  local episode_title=$(_videos_get_episode_title "$episode_url")

  if _videos_is_episode_downloaded "$episode_url"; then
    log_debug "episode already downloaded: $episode_title"
    return 0
  fi

  log_info "downloading episode: $episode_title"

  local download_options="--no-color -q --extract-audio --audio-format aac"
  local output_file="$conf_videos_download_path/podcasts/$podcast_name/$episode_title.aac"

  mkdir -p "$(dirname "$output_file")"

  $conf_videos_youtube_download_cmd $download_options -o "$output_file" "$episode_url" || {
    log_warn "failed to download episode: $episode_title"
    return 1
  }

  _videos_remove_advertisements "$output_file"

  echo "$episode_url" >>"$conf_videos_download_path/podcasts/downloaded"

  log_info "downloaded episode: $episode_title"
}

_videos_get_episode_title() {
  local episode_url=$1

  printf '%s\n' "$episode_url" | sed -e 's|.*/\([^/]*\)\.[^.]*$|\1|' -e 's|.*/\([^/]*\)$|\1|'
}

_videos_is_episode_downloaded() {
  local episode_url=$1

  grep -q "^$episode_url$" "$conf_videos_download_path/podcasts/downloaded" 2>/dev/null
}

_videos_remove_advertisements() {
  local audio_file=$1

  log_debug "advertisement detection disabled"
}
