_configuration_create_from() {
  [ -e $APP_DATA_PATH ] && {
    _stdin_continue_if "configuration dir already exists @ $APP_DATA_PATH, delete?" "Y/n" || exit_with_error "user aborted"

    rm -rf $APP_DATA_PATH
  }

  local configuration_copy=$(_mktemp_options=d _mktemp_mktemp)
  exit_defer rm -rf $configuration_copy

  log_info "creating configuration from $1"

  git clone $1 $configuration_copy/git || exit_with_error "unable to clone $1"

  cd $configuration_copy/git

  git init $APP_DATA_PATH
  tar -cp --exclude='*/.git/*' -f - . | tar -xp -C $APP_DATA_PATH

  cd $APP_DATA_PATH
  git add .
  git commit -m "created from $1"

  log_info "configuration created from $1"
}
