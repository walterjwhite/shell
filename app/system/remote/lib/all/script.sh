script_exec() {
  [ $conf_log_level -gt 0 ] && exit_defer rm -f $1

  sh $1
}
