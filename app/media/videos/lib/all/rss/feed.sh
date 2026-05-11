_fetch_rss_feeds() {
  local current_feed=""

  printf '%s\n' "$conf_videos_podcast_feeds" | while IFS= read -r line; do
    current_feed="$current_feed $(printf '%s' "$line" | sed 's/ *\\$//')"

    if ! printf '%s' "$line" | grep -q '\\$'; then
      current_feed=$(printf '%s' "$current_feed" | sed 's/^ *//;s/ *$//') # trim whitespace

      podcast_channel_title=$(printf '%s' "$current_feed" | cut -d'|' -f1)
      rss_feed_url=$(printf '%s' "$current_feed" | cut -d'|' -f2)

      local feed_context=$(printf '%s' "$rss_feed_url" | sed 's|.*://||')
      log_add_context "$feed_context"
      _fetch_rss_feed
      _filter_rss_feed
      log_remove_context

      current_feed="" # reset for next feed
    fi
  done
}
_fetch_rss_feed() {
  log_info "fetching rss feed"

  feed_xml=$(_mktemp_mktemp)
  exit_defer rm -f "$feed_xml"

  curl -sSL --fail "$rss_feed_url" -o "$feed_xml" || exit_with_error "failed to fetch $rss_feed_url"
}

_filter_rss_feed() {
  log_info "filtering rss feed"

  extract_audio=1

  unset podcast_url podcast_title podcast_guid podcast_publish_date podcast_duration

  xmlstarlet sel -t -m '//item' \
    -v 'normalize-space(enclosure[1]/@url)' -o $'\t' \
    -v 'normalize-space(title[1])' -o $'\t' \
    -v 'normalize-space(guid[1])' -o $'\t' \
    -v 'normalize-space(pubDate[1])' -o $'\t' \
    -v 'normalize-space(itunes:duration[1])' -n "$feed_xml" |
    while IFS=$'\t' read -r podcast_url podcast_title podcast_guid podcast_publish_date podcast_duration; do
      [ -z "$podcast_url" ] && {
        log_warn "podcast_url is empty"
        continue
      }

      [ -z "$podcast_duration" ] && {
        log_warn "podcast duration is empty"
        continue
      }

      case $podcast_duration in
      *[0-9]:[0-9]*:[0-9]*)
        podcast_duration=$(echo "$podcast_duration" | awk -F: '{print ($1 * 3600) + ($2 * 60) + $3}')
        ;;
      esac

      podcast_publish_date_epoch="$(date_to_epoch "$podcast_publish_date")"
      [ "$podcast_publish_date_epoch" -eq 0 ] && {
        log_warn "podcast_publish_date_epoch is 0"
        continue
      }


      _podcast_filter || {
        log_debug "podcast_filter returned non-zero"
        continue
      }

      log_warn "downloading podcast: $podcast_title -> $podcast_url"
      _podcast_write_metadata
      _video_download
    done
}

date_to_epoch() {
  epoch="$(date -d "$1" +%s 2>/dev/null || true)"
  [ -z "$epoch" ] && printf '0\n' || printf '%s\n' "$epoch"
}

_podcast_write_metadata() {
  video_file=queued/$(_videos_date)
  mkdir -p "$(dirname "$video_file")"
  _time_seconds_to_human_readable $podcast_duration
  printf '%s|%s|%s|%s|%s|%s|%s|%s|%s\n' "$podcast_url" "$(date +%Y/%m/%d)" "$_human_readable_time" "$podcast_title" \
    "$podcast_channel_title" "" "" "1" "" >"$video_file"

  _videos_git $video_file
}
