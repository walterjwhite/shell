lib teams.sh

_ON_GH_OPEN_PR_TEAMS() {
  validation_require "$conf_dev_gh_open_pr_teams_message" conf_dev_gh_open_pr_teams_message
  validation_require "$conf_dev_gh_open_pr_webhook_urls" conf_dev_gh_open_pr_webhook_urls

  local teams_message=$(printf "$conf_dev_gh_open_pr_teams_message" "$_CONSOLE_CONTEXT_ID - $_CONSOLE_CONTEXT_DESCRIPTION" "$pr_url")
  _send_teams_message "$conf_dev_gh_open_pr_webhook_urls" "$teams_message"
}
