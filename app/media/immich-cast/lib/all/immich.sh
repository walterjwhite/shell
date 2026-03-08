_is_cache_valid() {
  local today=$(date +%Y-%m-%d)

  if [ ! -f "$conf_immich_memories_cache_date_file" ]; then
    return 1
  fi

  local cached_date=$(head -1 "$conf_immich_memories_cache_date_file")
  [ "$cached_date" = "$today" ]
}

_mark_cache_valid() {
  local today=$(date +%Y-%m-%d)
  printf '%s\n' "$today" >"$conf_immich_memories_cache_date_file"
}

fetch_memories() {
  if _is_cache_valid && [ -f "$conf_immich_memories_image_list_file" ] && [ -s "$conf_immich_memories_image_list_file" ]; then
    local count=$(wc -l <"$conf_immich_memories_image_list_file")
    log_detail "using cached memories ($count images)"
    return 0
  fi

  local today=$(date +%Y-%m-%d)
  local month_day=$(date +%m-%d)

  log_detail "fetching memories for $month_day..."

  mkdir -p $conf_immich_memories_cache_dir
  truncate -s 0 "$conf_immich_memories_image_list_file"

  for years in $(seq 1 $conf_immich_memories_max_years_ago); do
    _query_images_for_year
  done

  local count=$(wc -l <"$conf_immich_memories_image_list_file")
  log_detail "found $count images"

  if [ "$count" -eq 0 ]; then
    log_detail "no memories found for today"
    return 1
  fi

  _mark_cache_valid
  download_images

  return 0
}

_query_images_for_year() {
  local target_year=$(($(date +%Y) - years))
  local target_date="${target_year}-${month_day}"

  log_detail "  checking $years year(s) ago: $target_date"

  curl -s -X POST \
    "${conf_immich_memories_server_url}/api/search/metadata" \
    -H "x-api-key: ${conf_immich_memories_api_key}" \
    -H "Accept: application/json" \
    -H "Content-Type: application/json" \
    -d "{
      \"takenAfter\": \"${target_date}T00:00:00.000Z\",
      \"takenBefore\": \"${target_date}T00:00:00.999Z\",
      \"type\": \"IMAGE\"
    }" | jq -r '.assets.items[]? | select(.type == "IMAGE") | .id' | while read -r asset_id; do
    printf '%s/api/assets/%s/original\n' "${conf_immich_memories_server_url}" "${asset_id}" >>"$conf_immich_memories_image_list_file"
  done
}

download_images() {
  rm -rf "$conf_immich_memories_downloads"
  mkdir -p "$conf_immich_memories_downloads"

  log_detail "downloading images..."

  local index=1
  while IFS= read -r url; do
    local filename=$(printf "%03d.jpg" $index)
    log_detail "  downloading image $index..."

    curl -s -X GET "$url" \
      -H "x-api-key: ${conf_immich_memories_api_key}" \
      -o "$conf_immich_memories_downloads/$filename"

    index=$((index + 1))
  done <"$conf_immich_memories_image_list_file"

  log_detail "downloaded $((index - 1)) images"
}
