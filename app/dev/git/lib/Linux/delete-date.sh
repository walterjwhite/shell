_git_delete_date() {
  date --date="$(date) - $conf_git_delete_period_in_days day" +%Y/%m/%d
}
