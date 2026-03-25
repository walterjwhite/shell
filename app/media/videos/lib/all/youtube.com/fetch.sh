_youtube_fetch_channel() {
  _all_json_items="[]"
  _page=1
  _page_token=""
  _total=0
  _all_video_ids=""

  log_add_context "youtube_fetch_channel"
  log_add_context "$youtube_channel_id"

  while true; do
    log_info "fetching page ${_page} of up to ${conf_videos_yt_max_pages}"

    _page_json=$(yt_search \
      "$youtube_channel_id" \
      "$_published_after" \
      "$_page_token") || exit 1

    _item_count=$(printf '%s' "$_page_json" | jq '.items | length')
    log_debug "items on this page: ${_item_count}"

    if [ "$_item_count" -eq 0 ]; then
      log_debug "no more items"
      break
    fi

    _idx=0
    while [ "$_idx" -lt "$_item_count" ]; do
      _item=$(printf '%s' "$_page_json" | jq ".items[${_idx}]")

      _video_id=$(printf '%s' "$_item" | jq -r '.id.videoId')
      if [ -n "$_all_video_ids" ]; then
        _all_video_ids="${_all_video_ids},${_video_id}"
      else
        _all_video_ids="$_video_id"
      fi

      _all_json_items=$(printf '%s\n%s' \
        "$_all_json_items" \
        "[$_item]" |
        jq -s 'add')

      _idx=$((_idx + 1))
      _total=$((_total + 1))
    done

    _next_token=$(printf '%s' "$_page_json" |
      jq -r '.nextPageToken // empty')

    if [ -z "$_next_token" ]; then
      log_debug "no nextPageToken — reached last page"
      break
    fi

    if [ "$_page" -ge "$conf_videos_yt_max_pages" ]; then
      log_debug "reached max pages (${conf_videos_yt_max_pages})"
      break
    fi

    _page_token="$_next_token"
    _page=$((_page + 1))
  done

  if [ -n "$_all_video_ids" ]; then
    log_debug "fetching durations for ${_total} video(s)"
    _durations_json=$(_youtube_video_duration "$_all_video_ids")

    _all_json_items=$(printf '%s' "$_all_json_items" | jq \
      --argjson durations "$_durations_json" \
      'map(. + {duration: ("\(.id.videoId)" as $vid | $durations.items[] | select(.id == $vid) | .contentDetails.duration | 
        gsub("PT"; "") | 
        gsub("H"; "h") | 
        gsub("M"; "m") | 
        gsub("S"; "s") | 
        if test("h") then (capture("(?<hours>\\d+)h").hours | tonumber) * 3600
        elif test("m") then (capture("(?<minutes>\\d+)m").minutes | tonumber) * 60
        elif test("s") then (capture("(?<seconds>\\d+)s").seconds | tonumber)
        elif test("\\d+h\\d+m") then 
          (capture("(?<hours>\\d+)h(?<minutes>\\d+)m").hours | tonumber) * 3600 + (capture("(?<hours>\\d+)h(?<minutes>\\d+)m").minutes | tonumber) * 60
        elif test("\\d+h\\d+s") then 
          (capture("(?<hours>\\d+)h(?<seconds>\\d+)s").hours | tonumber) * 3600 + (capture("(?<hours>\\d+)h(?<seconds>\\d+)s").seconds | tonumber)
        elif test("\\d+m\\d+s") then 
          (capture("(?<minutes>\\d+)m(?<seconds>\\d+)s").minutes | tonumber) * 60 + (capture("(?<minutes>\\d+)m(?<seconds>\\d+)s").seconds | tonumber)
        elif test("\\d+h\\d+m\\d+s") then 
          (capture("(?<hours>\\d+)h(?<minutes>\\d+)m(?<seconds>\\d+)s").hours | tonumber) * 3600 + (capture("(?<hours>\\d+)h(?<minutes>\\d+)m(?<seconds>\\d+)s").minutes | tonumber) * 60 + (capture("(?<hours>\\d+)h(?<minutes>\\d+)m(?<seconds>\\d+)s").seconds | tonumber)
        else 0 end)})')
  fi

  printf '%s' "$_all_json_items" | jq '.'

  log_info "${_total} video(s) found"
  log_remove_context
  log_remove_context
}

_youtube_video_duration() {
  curl -sS -H 'Accept: application/json' \
    "https://www.googleapis.com/youtube/v3/videos?part=contentDetails&id=${1}&key=${conf_videos_yt_api_key}"
}
