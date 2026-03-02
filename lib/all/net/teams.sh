_teams_send_message() {
  local _webhook_urls=$1
  local _message=$2
  printf '%s\n' "$_webhook_urls" | tr '|' '\n' |
    xargs -P$conf_install_teams_message_parallelization -I % \
      curl -H 'Content-Type: application/json' -d "{\"text\": \"$_message\"}" % >/dev/null
}
