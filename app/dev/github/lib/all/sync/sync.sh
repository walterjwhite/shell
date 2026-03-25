_github_iterate() {


  _github_setup_clone || return 1

  cd $setup_github_clone_project_path

  _github_sync

  scan

  exec_wrap git add .

  if [ $conf_github_review -eq 1 ]; then
    gd || return 1
  fi

  _stdin_continue_if "Continue with staging changes to github?" "Y/n"
}

_github_iterate_cleanup() {
  log_warn "_github_iterate_cleanup: $setup_github_clone_sync_path"
  rm -rf $setup_github_clone_project_path
}
