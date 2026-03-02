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
  for app in $(find . -maxdepth $conf_install_app_build_depth -type f ! -path '*/.*/*' -and -name .app | sed -e 's/\.app$//' | sort -u); do
    cd $app
    _app_build_instance
    cd $build_wd
  done
}

_app_build_instance() {
  target_application_name=$(basename $PWD)
  log_add_context $target_application_name

  log_info "building"

  mkdir -p $ARTIFACTS_PATH/$target_application_name

  _app_build_determine_build_platforms
  _app_build_platforms

  log_remove_context
}
