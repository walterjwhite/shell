_date_human_readable_to_unix_epoch() {
  date -j -f "%b %d, %Y %I:%M %p" "$1" +%s
}
