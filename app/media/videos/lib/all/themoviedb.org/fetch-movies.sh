_tmdb_fetch_movies() {
  local date_from=$(date -d "-${conf_videos_movie_trailer_days_back} days" '+%Y-%m-%d' 2>/dev/null ||
    date -v "-${conf_videos_movie_trailer_days_back}d" '+%Y-%m-%d') # macOS fallback
  local date_to=$(date -d "+${conf_videos_movie_trailer_days_ahead} days" '+%Y-%m-%d' 2>/dev/null ||
    date -v "+${conf_videos_movie_trailer_days_ahead}d" '+%Y-%m-%d')

  log_info "fetching movies: without_genre=${conf_videos_movie_trailer_exclude_genres} | window=${date_from} → ${date_to} | max=${conf_videos_movie_trailer_fetch_count}"

  local collected=0 page=1 all_movies="[]"

  while [ $collected -lt $conf_videos_movie_trailer_fetch_count ]; do
    local page_json
    page_json=$(_tmdb_get "/discover/movie" \
      "without_genres=${conf_videos_movie_trailer_exclude_genres}" \
      "primary_release_date.gte=${date_from}" \
      "primary_release_date.lte=${date_to}" \
      "vote_count.gte=${conf_videos_movie_trailer_min_votes}" \
      "sort_by=${conf_videos_movie_trailer_sort_by}" \
      "region=${conf_videos_movie_trailer_region}" \
      "with_origin_country=${conf_videos_movie_trailer_origin_country}" \
      "page=${page}") || break

    local page_results total_pages
    page_results=$(printf '%s' "$page_json" | jq '.results | length')
    total_pages=$(printf '%s' "$page_json" | jq '.total_pages')

    [ "$page_results" -eq 0 ] && break

    all_movies=$(printf '%s\n%s' "$all_movies" \
      "$(printf '%s' "$page_json" | jq '.results')" |
      jq -s 'add')

    collected=$(printf '%s' "$all_movies" | jq 'length')

    log_detail "  Page ${page}/${total_pages} — collected ${collected} movies so far"

    [ $page -ge $total_pages ] && break

    page=$(($page + 1))
  done

  printf '%s' "$all_movies" | jq --argjson n "$conf_videos_movie_trailer_fetch_count" '.[0:$n]'
}
