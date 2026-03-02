exit_with_error() {
  [ -n "$exit_status" ] && return

  if [ $# -ge 2 ]; then
    exit_status=$2
  else
    exit_status=1
  fi

  [ -n "$3" ] && {
    _exit_print_line $3
  }

  exit_log_level=4
  exit_status_code="ERR"
  exit_color_code="$conf_log_c_err"

  exit_message="$1 ($exit_status)"
  exit_beep="$conf_log_beep_err"

  exit_defer _environment_dump
  exit_defer _exit_log_app_exit

  _exit_run_defers

  exit $exit_status
}

exit_with_success() {
  [ -n "$exit_status" ] && return

  exit_status=0

  exit_log_level=1
  exit_status_code="SCS"
  exit_color_code="$conf_log_c_scs"

  exit_message="$1"
  [ -z "$exit_message" ] && exit_message="success"

  exit_beep="$conf_log_beep_scs"

  exit_defer _alert_long_running_cmd
  exit_defer _exit_log_app_exit

  _exit_run_defers

  exit $exit_status
}

_exit_on_hup() {
  log_info "hup received"
}

_exit_on_int() {
  exit_with_error "interrupted" $? $1
}

_exit_on_quit() {
  exit_with_error "quit" $? $1
}

_exit_on_illegal() {
  exit_with_error "illegal instruction" $? $1
}

_exit_on_abort() {
  exit_with_error "abort" $? $1
}

_exit_on_alarm() {
  exit_with_error "alarm" $? $1
}

_exit_on_term() {
  exit_with_error "term" $? $1
}


_exit_print_line() {
  log_warn "unhandled error"

  local _exception_line
  _exception_line=$($GNU_SED -n "${1}p" $0)
  printf '  %s @ %s:%s\n' "$_exception_line" $0 $1
}

exit_defer() {
  log_debug "deferring: $1"
  if [ $# -gt 1 ]; then
    local _defer_with_args
    _defer_with_args=$(printf '%s' "$*" | sed -e 's/ /:/' -e 's/ /,/g')
    exit_defers="$_defer_with_args $exit_defers"
  else
    exit_defers="$1 $exit_defers"
  fi
}

_exit_run_defers() {
  [ -z "$exit_defers" ] && return 1

  for exit_defer in $exit_defers; do
    case "$exit_defer" in
    *:*)
      local _func_name=$(printf '%s' "$exit_defer" | cut -d':' -f1)
      local _args=$(printf '%s' "$exit_defer" | cut -d':' -f2 | tr ',' ' ')

      exec_call $_func_name $_args 2>/dev/null
      ;;
    *)
      exec_call $exit_defer 2>/dev/null
      ;;
    esac
  done

  unset exit_defers
}

_exit_log_app_exit() {
  [ "$exit_message" ] && {
    if [ -z "$APPLICATION_START_TIME" ]; then
      unset exit_beep
    else
      local _current_time
      local _timeout
      _current_time=$(date +%s)

      _timeout=$(($APPLICATION_START_TIME + $conf_log_beep_timeout))
      [ $_current_time -le $_timeout ] && unset exit_beep
    fi

    log_print_log $exit_log_level "$exit_status_code" "$exit_color_code" "$exit_beep" "$exit_message"
  }

  log_app exit

  [ -n "$log_logfile" ] && [ -n "$optn_log_exit_cmd" ] && {
    $optn_log_exit_cmd -file $log_logfile
  }
}

