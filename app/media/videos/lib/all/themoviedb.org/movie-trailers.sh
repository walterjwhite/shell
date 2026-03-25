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

_download_trailer() {
  local youtube_video_url="${YOUTUBE_BASE}?v=${trailer_key}"
  log_info "downloading trailer: $youtube_video_url | $movie_genre_id_names"

  vq -videos-url="${youtube_video_url}" -videos-tags="movie trailer $movie_genre_id_names $movie_certification"
}
