_configuration_create_from() {
  [ -e ~/.data/configuration ] && {
    _stdin_continue_if "configuration dir already exists @ ~/.data/configuration, delete?" "Y/n" || exit_with_error "user aborted"

    rm -rf ~/.data/configuration
  }

  local configuration_copy=$(_mktemp_options=d _mktemp_mktemp)
  exit_defer rm -rf $configuration_copy

  log_info "creating configuration from $1"

  git clone $1 $configuration_copy/git || exit_with_error "unable to clone $1"

  cd $configuration_copy/git

  git init ~/.data/configuration
  tar -cp --exclude='*/.git/*' -f - . | tar -xp -C ~/.data/configuration

  cd ~/.data/configuration
  git add .
  git commit -m "created from $1"

  log_info "configuration created from $1"
}
