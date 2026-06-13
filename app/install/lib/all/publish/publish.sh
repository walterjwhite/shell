_app_publish_recursive() {
  local app
  local publish_wd=$PWD
  find . -maxdepth "$conf_install_app_build_depth" -type f ! -path '*/.*/*' -name .app |
    sed -e 's/\/\.app$//' -e 's/^\.\///' | sort -u |
    while IFS= read -r app; do
      cd "$app" || {
        log_warn "cannot cd to $app"
        continue
      }
      _app_publish_instance
      cd "$publish_wd" || exit_with_error "cannot return to publish working directory: $publish_wd"
    done
}

_app_publish_instance() {
  target_application_name=$(basename "$PWD")

  target_application_version=$(git rev-parse --short=8 HEAD)

  file_require "$ARTIFACTS_PATH/$target_application_name" "No artifacts to publish"

  _app_is_app
  _git_is_clean .

  _prepare_registry
  _update_artifacts
  _push_changes
}
