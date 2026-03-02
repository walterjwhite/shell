_time_delay() {
  local current_epoch_time=$(date +%s)

  local future_epoch_time=$(date -d "$_EXECUTION_TIME" +%s)

  local _delay=$(($future_epoch_time - $current_epoch_time))

  [ $_delay -lt 0 ] && {
    case $_EXECUTION_TIME in
    [0-2][0-9]:[0-5][0-9] | [0-2][0-9][0-5][0-9]) ;;
    [0-2][0-9]:[0-5][0-9]:[0-5][0-9] | [0-2][0-9][0-5][0-9][0-5][0-9]) ;;
    *)
      exit_with_error "date/time has already passed: $_EXECUTION_TIME"
      ;;
    esac

    log_warn "time already passed, running immediately"
    return
  }

  log_info "waiting ${_delay}s"
  sleep $_delay &

  wait $!
}

_time_delay_duration() {
  [ -z "$1" ] && return 1

  local _delay=0
  case $1 in
  *h)
    _delay=${1%h}
    _delay=$(($_delay * 3600))
    ;;
  *m)
    _delay=${1%m}
    _delay=$(($_delay * 60))
    ;;
  *s)
    _delay=${1%s}
    ;;
  *)
    _delay=$1
    ;;
  esac

  [ $_delay -le 0 ] && exit_with_error "computed delay < 0"

  log_detail "waiting ${_delay}s"
  sleep $_delay &

  wait $!
}
