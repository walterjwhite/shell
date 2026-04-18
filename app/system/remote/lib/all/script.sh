script_exec() {
  [ $conf_log_level -gt 0 ] && exit_defer rm -f $1

  timeout $conf_remote_timeout sh $1
}
