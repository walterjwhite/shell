_app_publish_recursive() {
  local app
  local publish_wd=$PWD
  for app in $(find . -maxdepth $conf_install_app_build_depth -type f ! -path '*/.*/*' -and -name .app | sed -e 's/\/\.app$//' -e 's/^\.\///' | sort -u); do
    cd $app
    _app_publish_instance
    cd $publish_wd
  done
}

_app_publish_instance() {
  target_application_name=$(basename $PWD)

  target_application_version=$(git rev-parse --short=8 HEAD)

  file_require $ARTIFACTS_PATH/$target_application_name "No artifacts to publish"

  _app_is_app
  _git_is_clean .

  _prepare_registry
  _update_artifacts

  if [ -n "$(git status --porcelain $target_application_name)" ]; then
    log_info "publishing changes"
    _push_changes
  else
    log_warn "no changes detected"
  fi
}
