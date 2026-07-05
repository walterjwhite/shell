_git_delete_date() {
  date -v -${conf_git_delete_period_in_days}d +%Y/%m/%d
}
