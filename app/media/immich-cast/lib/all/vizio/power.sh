_vizio_do_on() {
  _vizio_do_status
  case $? in
  1)
    log_debug "tv is already on"
    return 0
    ;;
  0)

    _vizio_do_wake
    ;;
  *)
    exit_with_error "unknown status"
    ;;
  esac
}

_vizio_do_wake() {
  validation_require "$vizio_mac" vizio_mac
  wakeonlan "$vizio_mac"
}

_vizio_do_off() {
  _vizio_do_status
  case $? in
  1)
    _vizio_api PUT /key_command/ '{"KEYLIST": [{"CODESET": 11, "CODE": 0, "ACTION": "KEYPRESS"}]}' >/dev/null 2>&1
    ;;
  0)
    log_detail "tv is already in standby mode"
    ;;
  *)
    exit_with_error "unknown status"
    ;;
  esac
}

_vizio_do_status() {
  local response_value=$(_vizio_api GET /state/device/power_mode | grep -o '"VALUE": [0-9]*' | grep -o '[0-9]*$')
  return $response_value
}
