yt_search() {
  _channel_id="$1"
  _published_after="$2"
  _page_token="$3" # may be empty for first page

  _qs="part=snippet"
  _qs="${_qs}&channelId=$(_utils_urlencode "$_channel_id")"
  _qs="${_qs}&publishedAfter=$(_utils_urlencode "$_published_after")"
  _qs="${_qs}&type=$(_utils_urlencode "$conf_videos_yt_type")"
  _qs="${_qs}&order=$(_utils_urlencode "$conf_videos_yt_order")"
  _qs="${_qs}&maxResults=${conf_videos_yt_max_results}"
  _qs="${_qs}&key=$(_utils_urlencode "$conf_videos_yt_api_key")"
  if [ -n "$_page_token" ]; then
    _qs="${_qs}&pageToken=$(_utils_urlencode "$_page_token")"
  fi

  _url="${YT_SEARCH_URL}?${_qs}"

  log_info "get search.list (pageToken=${_page_token:-<first>}) ..."

  _response=$(curl -sS \
    -H "Accept: application/json" \
    -w '\n__HTTP_STATUS__%{http_code}' \
    "$_url") || {
    exit_with_error "curl request failed."
  }

  _http_code=$(printf '%s' "$_response" | grep -o '__HTTP_STATUS__[0-9]*' | sed 's/__HTTP_STATUS__//')
  _body=$(printf '%s' "$_response" | sed 's/__HTTP_STATUS__[0-9]*$//')

  if [ "$_http_code" -lt 200 ] || [ "$_http_code" -ge 300 ]; then
    _api_msg=$(printf '%s' "$_body" |
      jq -r '.error.message // "unknown error"' 2>/dev/null ||
      echo "unknown error")
    exit_with_error "youtube API HTTP ${_http_code}: ${_api_msg}"
  fi

  printf '%s' "$_body"
}
