_beep_beep() {
  [ $# -eq 0 ] && return 1

  if [ -n "$beeping" ]; then
    log_debug "another 'beep' is in progress"
    return 2
  fi

  beeping=1
  _do_beep "$@" &
}

_do_beep() {

  powershell "[console]::beep($1)"

  unset beeping
}
