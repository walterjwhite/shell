_app_build() {
  project_root=$(git rev-parse --show-toplevel)
  _settings_init

  if [ ! -e .app ]; then
    log_warn "no .app file found, attempting to build apps recursively"
    _app_build_recursive
    return
  fi

  _app_build_instance
}

_app_build_recursive() {
  local app
  local build_wd=$PWD
  local _requested_build_platforms="$build_platforms"
  local _requested_build_all_platforms="$build_all_platforms"
  find . -maxdepth "$conf_install_app_build_depth" -type f ! -path '*/.*/*' -name .app |
    sed -e 's/\.app$//' | sort -u |
    while IFS= read -r app; do
      cd "$app" || {
        log_warn "cannot cd to $app"
        continue
      }
      build_platforms="$_requested_build_platforms"
      build_all_platforms="$_requested_build_all_platforms"
      _app_build_instance
      cd "$build_wd" || exit_with_error "cannot return to build working directory: $build_wd"
    done
}

_app_build_instance() {
  target_application_name=$(basename "$PWD")
  log_add_context "$target_application_name"

  log_info "building"

  mkdir -p "$ARTIFACTS_PATH/$target_application_name"

  _app_build_determine_build_platforms
  _app_build_platforms

  log_remove_context
}
