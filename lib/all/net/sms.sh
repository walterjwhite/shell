_sms_send() {
  if [ $# -lt 4 ]; then
    log_warn "carrier[1], number[2], subject[3], message[4] is required - $# arguments provided"
    return 1
  fi

  local _carrier
  _carrier=$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')
  shift

  local _sms_email_domain
  local _mms_email_domain

  case $_carrier in
  att)
    _sms_email_domain=txt.att.net
    _mms_email_domain=mms.att.net
    ;;
  boost)
    _sms_email_domain=smsmyboostmobile.com
    _mms_email_domain=myboostmobile.com
    ;;
  cricket)
    _sms_email_domain=sms.cricketwireless.net
    _mms_email_domain=mms.cricketwireless.net
    ;;
  sprint)
    _sms_email_domain=messaging.sprintpcs.com
    _mms_email_domain=pm.sprint.com
    ;;
  tmobile)
    _sms_email_domain=tmomail.net
    _mms_email_domain=tmomail.net
    ;;
  us-cellular)
    _sms_email_domain=email.uscc.net
    _mms_email_domain=mms.uscc.net
    ;;
  verizon)
    _sms_email_domain=vtext.com
    _mms_email_domain=vzwpix.com
    ;;
  virgin)
    _sms_email_domain=vmobl.com
    _mms_email_domain=vmpix.com
    ;;
  *)
    exit_with_error "unsupported carrier: $_carrier"
    ;;
  esac

  _mail_send "$1@$_sms_email_domain" "$2" "$3"
}
