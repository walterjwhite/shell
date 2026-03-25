_tmdb_get() {
  local path="$1"
  shift

  local qs="api_key=${conf_videos_the_movie_database_api_key}&language=${conf_videos_movie_trailer_language}"
  for param in "$@"; do
    qs="${qs}&${param}"
  done

  local url="${TMDB_BASE}${path}?${qs}"
  log_debug "get ${TMDB_BASE}${path}"

  local response http_code body
  response=$(curl -sS --fail-with-body \
    -H "Accept: application/json" \
    -w '\n__HTTP_STATUS__%{http_code}' \
    "$url") || {
    exit_with_error "curl failed for ${url}"
  }

  http_code=$(printf '%s' "$response" | grep -o '__HTTP_STATUS__[0-9]*' | sed -e 's/__HTTP_STATUS__//')
  body=$(printf '%s' "$response" | sed 's/__HTTP_STATUS__[0-9]*$//')

  [ "$http_code" -lt 200 ] || [ "$http_code" -ge 300 ] && {
    tmdb_msg=$(printf '%s' "$body" | jq -r '.status_message // "unknown error"' 2>/dev/null || echo "unknown error")
    exit_with_error "tmdb HTTP ${http_code}: ${tmdb_msg}"
  }

  printf '%s' "$body"
}

_tmdb_get_movie_certification() {
  _tmdb_get "/movie/${movie_id}/release_dates" | jq -r '
    .results[]
    | select(.iso_3166_1 == "US")
    | .release_dates[]
    | select(.certification != "" and .certification != null)
    | .certification
  ' | head -1
}
