_tmdb_fetch_movie_trailers() {
  _tmdb_get "/movie/${1}/videos" | jq '
    [ .results[]
      | select(.site == "YouTube" and .type == "Trailer")
    ]
    | if length == 0 then
        []
      else
        ( [ .[] | select(.name | ascii_downcase | test("official")) ]
          + .
        ) | unique_by(.key) | .[0:1]
      end
  '
}

_trailer_already_downloaded_for_movie() {
  local _data_path="${DATA_PATH}/${APPLICATION_NAME}"
  [ -d "$_data_path" ] || return 1
  grep -rqm1 "tmdb_id:$movie_id" "$_data_path/queued" "$_data_path/downloaded" "$_data_path/watched" 2>/dev/null
}

_download_trailer() {
  if [ -z "$force" ] && _trailer_already_downloaded_for_movie; then
    log_info "trailer for movie $movie_title already queued/downloaded, skipping (use -force to override)"
    return
  fi

  local youtube_video_url="${YOUTUBE_BASE}?v=${trailer_key}"
  log_info "downloading trailer: $youtube_video_url | $movie_genre_id_names"

  vq -videos-url="${youtube_video_url}" -videos-tags="movie trailer $movie_genre_id_names $movie_certification tmdb_id:$movie_id"
}
