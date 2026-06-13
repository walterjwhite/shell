log_warn() {
  log_print_log 3 WRN "${conf_log_c_wrn}" "${conf_log_beep_wrn}" "$1"
}

log_info() {
  log_print_log 2 INF "${conf_log_c_info}" "${conf_log_beep_info}" "$1"
}

log_detail() {
  log_print_log 2 DTL "${conf_log_c_detail}" "${conf_log_beep_detail}" "$1"
}

log_debug() {
  log_print_log 1 DBG "${conf_log_c_debug}" "${conf_log_beep_debug}" "($$) $1"
}
