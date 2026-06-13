_prepare_registry() {
  log_info "preparing registry"

  local publish_wd=$PWD
  if [ -e "$registry_path" ]; then
    cd "$registry_path" || exit_with_error "cannot cd to registry path: $registry_path"

    [ "$INSTALL_REGISTRY_OFFLINE" ] && {
      log_warn "registry is offline, not attempting to sync"
      return 1
    }

    git pull && log_detail "updated registry" || log_warn "unable to update registry"
  else
    _git_do_clone "$registry_url" "$registry_path" || exit_with_error "unable to clone app registry"
    cd "$registry_path" || exit_with_error "cannot cd to registry path: $registry_path"
  fi

}

_update_artifacts() {
  log_info "updating artifacts for $target_application_name"

  local app_platform
  for app_platform in $(ls "$ARTIFACTS_PATH/$target_application_name"); do
    log_add_context "$app_platform"

    rm -rf "$target_application_name/$app_platform"
    mkdir -p "$target_application_name/$app_platform"

    unset files

    local files=""
    [ -e "$ARTIFACTS_PATH/$target_application_name/$app_platform/cfg" ] && files="cfg"
    [ -e "$ARTIFACTS_PATH/$target_application_name/$app_platform/setup" ] && files="$files setup"
    [ -e "$ARTIFACTS_PATH/$target_application_name/$app_platform/post-setup" ] && files="$files post-setup"

    [ -z "$files" ] && {
      log_warn 'no files'
      log_remove_context
      continue
    }

    tar cp -C "$ARTIFACTS_PATH/$target_application_name/$app_platform" $files |
      tar xp -C "$target_application_name/$app_platform"

    log_remove_context
  done
}
