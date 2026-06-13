script_exec() {
  [ $conf_log_level -gt 0 ] && exit_defer rm -f $1

  if [ -n "$remote_exec_profile" ]; then
    log_warn "using profile $remote_exec_profile"

    _include_optional $APP_CONFIG_PATH.$remote_exec_profile

    [ -n "$profile_user" ] && {
      log_warn "running as user $profile_user"
      sudo_run chown -R "$profile_user:$profile_user" .

      opwd=$PWD

      sudo_user=$profile_user
    }

  fi

  time_timeout $conf_remote_timeout "script_exec - $1" sh $1
  local status=$?

  [ -n "$profile_user" ] && {
    unset sudo_user
    cd /tmp

    local ouser=$USER
    sudo_run chown -R "$ouser:$ouser" $opwd
  }

  return $status
}
