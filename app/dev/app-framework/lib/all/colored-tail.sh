_colored_tail_show() {
  [ ! -e "$log_logfile" ] && {
    return 1
  }

  local escape_sequence=$(printf '\033')

  tail -f $log_logfile |
    sed -u -e "s, TRACE ,${escape_sequence}[34m&${escape_sequence}[0m," \
      -e "s, DEBUG ,${escape_sequence}[35m&${escape_sequence}[0m," \
      -e "s, INFO ,${escape_sequence}[36m&${escape_sequence}[0m," \
      -e "s, WARN ,${escape_sequence}[33m&${escape_sequence}[0m," \
      -e "s, ERROR ,${escape_sequence}[31m&${escape_sequence}[0m," >/dev/tty
}
