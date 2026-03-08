_date_human_readable_to_unix_epoch() {
  date -d "$1" +%s
}
