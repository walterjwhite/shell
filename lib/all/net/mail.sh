_mail_send() {
  [ -n "$conf_log_mail_disabled" ] && {
    log_warn "mail is disabled"
    return 1
  }

  if [ $# -lt 3 ]; then
    log_warn "recipients[0], subject[1], message[2] is required - $# arguments provided"
    return 2
  fi

  local _recipients
  _recipients=$(printf '%s' "$1" | tr '|' ' ')
  shift

  local _subject
  _subject="$1"
  shift

  local _message
  _message="$1"
  shift

  printf '%s\n' "$_message" | mail -s "$_subject" $_recipients
}
