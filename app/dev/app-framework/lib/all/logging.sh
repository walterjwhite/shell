_logging_capture_env() {
  printf '# run: %s:%s\n' "$(date)" "$PWD" >"$log_logfile"
  printf '# git: %s:%s\n' "$(gcb)" "$(git-head)" >>"$log_logfile"
  printf '# cmdline: %s\n' "$@" >>"$log_logfile"
  printf '# env - start\n' >>"$log_logfile"
  env | _sanitize_input >>"$log_logfile"
  printf '# env - end\n' >>"$log_logfile"
}
