_github_sync() {
  [ ! -e $setup_github_clone_project_path ] && exit_with_error "$setup_github_clone_project_path does not exist!"
  cd $setup_github_clone_project_path

  [ -z "$setup_github_clone_new" ] && exec_wrap git pull

  setup_github_clone_project_name=$(basename $PWD)

  _github_remove_contents
  _github_copy_source

  _git_remove_app_framework
  _git_remove_secrets
  _git_remove_artifacts
  _git_remove_comments
  _git_remove_patterns
  _git_remove_time

  if [ -n "$_OPTN_GITHUB_IGNORE" ]; then
    log_info "removing other filtered content: $_OPTN_GITHUB_IGNORE"
    exec_wrap rm -rf $_OPTN_GITHUB_IGNORE
  fi
}

_github_remove_contents() {
  log_detail "clearing repository contents $PWD"
  find . -mindepth 1 -maxdepth 1 ! -name .git ! -name '.' -exec rm -rf {} +
}

_github_copy_source() {
  log_detail "copying modified project contents"

  cd $git_project_path
  cp .app .github .gitignore $setup_github_clone_project_path >/dev/null 2>&1

  git archive HEAD | tar xp -C $setup_github_clone_project_path

  cd $setup_github_clone_project_path

  find . -name '.*' -or -name '*.secret*' -or -name github -or -name system-configuration -exec rm -rf {} +
}
