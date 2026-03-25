_compute_published_after() {
  if date --version >/dev/null 2>&1; then
    date -u -d "-${conf_videos_yt_days_back} days" '+%Y-%m-%dT%H:%M:%SZ'
  else
    date -u -v "-${conf_videos_yt_days_back}d" '+%Y-%m-%dT%H:%M:%SZ'
  fi
}

_utils_urlencode() {
  _input="$1"
  _encoded=""
  _len=${#_input}
  _i=0
  while [ "$_i" -lt "$_len" ]; do
    _char=$(printf '%s' "$_input" | cut -c$((_i + 1)))
    case "$_char" in
    [A-Za-z0-9._~-]) _encoded="${_encoded}${_char}" ;;
    *) _encoded="${_encoded}$(printf '%%%02X' "'$_char")" ;;
    esac
    _i=$((_i + 1))
  done
  printf '%s' "$_encoded"
}


_print_tsv() {
  printf '%s' "$1" | jq -r '
        .snippet.publishedAt + "\t" +
        .id.videoId          + "\t" +
        .snippet.title       + "\t" +
        "https://www.youtube.com/watch?v=" + .id.videoId
    '
}

_print_url() {
  printf '%s' "$1" | jq -r '"https://www.youtube.com/watch?v=" + .id.videoId'
}
