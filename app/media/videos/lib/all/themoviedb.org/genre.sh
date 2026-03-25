_tmdb_resolve_genre_id() {
  local genre_input="$1"

  if [[ "$genre_input" =~ ^[0-9]+$ ]]; then
    printf '%s\n' "$genre_input"
    return
  fi

  log_info "resolving genre name '${genre_input}' to TMDb genre ID..."
  local genres_json
  genres_json=$(_tmdb_get "/genre/movie/list")

  local genre_id
  genre_id=$(printf '%s' "$genres_json" |
    jq -r --arg name "$genre_input" \
      '.genres[] | select(.name | ascii_downcase == ($name | ascii_downcase)) | .id' |
    head -1)

  if [[ -z "$genre_id" ]]; then
    log_warn "genre '${genre_input}' not found. Available genres:"
    printf '%s' "$genres_json" |
      jq -r '.genres[] | "  \(.id)  \(.name)"' >&2
    exit_with_error "specify a valid genre name or numeric ID in conf_videos_movie_trailer_genre"
  fi

  log_info "resolved: '${genre_input}' → genre_id=${genre_id}"
  printf '%s\n' "$genre_id"
}
