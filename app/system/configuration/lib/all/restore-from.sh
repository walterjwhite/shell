_configuration_restore_from() {
  [ -e $APP_DATA_PATH ] && {
    _stdin_continue_if "configuration dir already exists @ $APP_DATA_PATH, delete?" "Y/n" || exit_with_error "user aborted"

    rm -rf $APP_DATA_PATH
  }

  log_info "restoring configuration from $1"
  git clone $1 $APP_DATA_PATH || exit_with_error "unable to clone $1"

  log_info "restored $1"

  action=restore
  _provider_run_all _configuration_action
}
