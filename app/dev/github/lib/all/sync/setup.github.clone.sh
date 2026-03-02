_github_setup_clone() {
  setup_github_clone_source_project=$PWD

  [ -e .github-project-name ] && git_project_name=$(head -1 .github-project-name)

  setup_github_clone_sync_path=$APP_DATA_PATH

  log_info "staging github sync: $git_project_name"

  setup_github_clone_project_path=$setup_github_clone_sync_path/$git_project_name

  if [ -e $setup_github_clone_project_path ]; then
    _stdin_continue_if "Remove existing github project $setup_github_clone_project_path" "Y/n" || exit_with_error "user aborted"
    rm -Rf $setup_github_clone_project_path
  fi

  setup_github_clone_username=$(secrets -out=stdout get $conf_github_username_key 2>/dev/null)
  validation_require "$setup_github_clone_username" "setup_github_clone_username - check secrets key: $conf_github_username_key"
  if [ -n "$git_project_name" ]; then
    setup_github_clone_project=ssh://git@github.com:/$setup_github_clone_username/$git_project_name
  else
    setup_github_clone_project=ssh://git@github.com:/$setup_github_clone_username/$git_project_name
  fi

  setup_github_clone_new=1

  exec_wrap git clone --depth 1 $setup_github_clone_project $setup_github_clone_project_path
}
