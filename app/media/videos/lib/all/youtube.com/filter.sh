_youtube_filter() {
  youtube_video_id=$(printf '%s\n' "$youtube_json_data" | jq -r '.id.videoId')
  youtube_video_title=$(printf '%s\n' "$youtube_json_data" | jq -r '.snippet.title' | sed -e 's/ | / - /g' -e 's/|/-/g')
  youtube_video_channel_title=$(printf '%s\n' "$youtube_json_data" | jq -r '.snippet.channelTitle')

  youtube_video_duration=$(printf '%s\n' "$youtube_json_data" | jq -r '.duration')

  log_debug "video id: $youtube_video_id, title: $youtube_video_title, channel: $youtube_video_channel_title, duration: $youtube_video_duration"

  _youtube_channel_filter
}
