_time_seconds_to_human_readable() {
  local _human_readable_time
  _human_readable_time=$(printf '%02d:%02d:%02d' $(($1 / 3600)) $(($1 % 3600 / 60)) $(($1 % 60)))
}

_time_human_readable_to_seconds() {
  local _time_in_seconds
  case $1 in
  *w)
    _time_in_seconds=${1%%w}
    _time_in_seconds=$(($_time_in_seconds * 3600 * 8 * 5))
    ;;
  *d)
    _time_in_seconds=${1%%d}
    _time_in_seconds=$(($_time_in_seconds * 3600 * 8))
    ;;
  *h)
    _time_in_seconds=${1%%h}
    _time_in_seconds=$(($_time_in_seconds * 3600))
    ;;
  *m)
    _time_in_seconds=${1%%m}
    _time_in_seconds=$(($_time_in_seconds * 60))
    ;;
  *s)
    _time_in_seconds=${1%%s}
    ;;
  *)
    exit_with_error "$1 was not understood"
    ;;
  esac
}

_time_decade() {
  local _year
  local _end_year
  local _event_decade_prefix
  local _event_decade_start
  local _event_decade_end

  _year=$(date +%Y)

  _end_year=$(printf '%s' $_year | head -c 4 | tail -c 1)
  _event_decade_prefix=$(printf '%s' "$_year" | $GNU_GREP -Po "[0-9]{3}")

  if [ "$_end_year" -eq "0" ]; then
    _event_decade_start=${_event_decade_prefix}
    _event_decade_start=$(printf '%s\n' "$_event_decade_start-1" | bc)

    _event_decade_end=${_event_decade_prefix}0
  else
    _event_decade_start=$_event_decade_prefix
    _event_decade_end=$_event_decade_prefix

    _event_decade_end=$(printf '%s\n' "$_event_decade_end+1" | bc)
    _event_decade_end="${_event_decade_end}0"
  fi

  _event_decade_start=${_event_decade_start}1

  printf '%s-%s' "$_event_decade_start" "$_event_decade_end"
}

_time_current_time() {
  date +$conf_log_date_time_format
}

_time_current_time_unix_epoch() {
  date +%s
}

time_timeout() {
  local _timeout=$1
  shift

  local _message=$1
  shift

  local _timeout_units='s'
  if [ $(printf '%s' "$_timeout" | grep -c '[smhd]{1}') -gt 0 ]; then
    unset _timeout_units
  fi

  local _sudo
  [ -n "$sudo_required" ] || [ -n "$sudo_user" ] && _sudo=sudo_run

  $_sudo timeout $options $_timeout "$@" || {
    local _error_status=$?
    local _error_message="Other error"
    if [ $_error_status -eq 124 ]; then
      _error_message="Timed Out"
    fi

    [ $timeout_err_function ] && $timeout_err_function

    local timeout_error_msg="time_timeout: $_error_message: ${_timeout}${_timeout_units} - $_message ($_error_status): $_sudo timeout $options $_timeout $* ($USER)"

    [ $warn_on_error ] && {
      log_warn "$timeout_error_msg"
      return $_error_status
    }

    exit_with_error "$timeout_error_msg"
  }
}
