_youtube_filter() {
  youtube_video_id=$(printf '%s\n' "$youtube_json_data" | jq -r '.id.videoId')
  youtube_video_title=$(printf '%s\n' "$youtube_json_data" | jq -r '.snippet.title')
  youtube_video_channel_title=$(printf '%s\n' "$youtube_json_data" | jq -r '.snippet.channelTitle')

  youtube_video_duration=$(printf '%s\n' "$youtube_json_data" | jq -r '.duration')

  _youtube_channel_filter
}
