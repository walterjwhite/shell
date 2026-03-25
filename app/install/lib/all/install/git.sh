_git_clone() {
  log_info "git clone: $target_application_name"
  is_git_repo=1

  _is_registry_online || {
    log_warn "registry is offline, attempting to use offline repository as-is"
    _git_app_dir_setup
    return
  }

  _git_do_clone $conf_install_app_registry_git_url $REGISTRY_PATH ||
    exit_with_error "unable to clone: $target_application_name in any of $conf_install_app_registry_git_url"

  if [ -n "$target_application_version_requested" ]; then
    log_detail "checking out version: $target_application_version_requested"
    (
      cd $REGISTRY_PATH && git_registry_version=$(_git_get_registry_hash_for_app_version)

      [ -z "$git_registry_version" ] && exit_with_error "$target_application_version_requested not found in registry"
      git checkout $git_registry_version
    ) || exit_with_error "unable to checkout version: $git_registry_version"
  fi

  _git_app_dir_setup
}

_git_get_registry_hash_for_app_version() {
  git log --grep="$git_platform:$git_target_application_name@$target_application_version_requested" --format='%h'
}

_git_app_dir_setup() {
  cd $REGISTRY_PATH

  [ ! -e $target_application_name ] && exit_with_error "$target_application_name does not exist in the registry"

  cd $target_application_name

  if [ -n "$is_git_repo" ]; then
    git_target_application_url=$(git remote -v | awk {'print$2'} | head -1)
    target_application_version=$(git log -1 --grep="$APP_PLATFORM_PLATFORM:$target_application_name@.*" --format=%B | sed -e 's/^.*@//' | head -1)
    target_application_build_date=$(git log -1 --grep="$APP_PLATFORM_PLATFORM:$target_application_name@.*" --format=%cd | head -1)

    [ -z "$target_application_version" ] && {
      log_warn "platform: $APP_PLATFORM_PLATFORM"
      log_warn "app name: $target_application_name"
      pwd
      git log -1 | cat -
      exit_with_error "error parsing version from git log"
    }
  else
    log_warn "installed from zip, needs implemented"
  fi

  log_detail "$target_application_name exists @ $target_application_version"
}

_git_has_updates() {
  local local_repository_version=$(_git_local_repository_version)
  local remote_repository_version=$(_git_remote_repository_version)

  [ "$local_repository_version" != "$remote_repository_version" ]
}

_git_local_repository_version() {
  git --git-dir=$REGISTRY_PATH/.git rev-parse --short HEAD
}

_git_remote_repository_version() {
  git ls-remote $conf_install_app_registry_git_url HEAD | cut -c1-9
}
