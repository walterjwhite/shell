search_git_activity() {
  if [ ! -e $git_project_path/.activity ]; then
    log_warn "no activity in $git_project_path/.activity"
    return
  fi

}
