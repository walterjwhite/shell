lib git/include.sh
lib git/project.directory.sh

_github_iterate_main() {
  _pwd=$PWD

  log_add_context "$APPLICATION_CMD"

  if [ -z "$git_status_recursive" ]; then
    _git_in_working_directory || {
      log_info "running $APPLICATION_CMD recursively"

      local git_status_recursive=1
      find . \( -type d -or -type f \) -and -name '.git' -execdir $APPLICATION_CMD \;
      exit
    }
  fi

  [ -e .github.sync.ignore ] && {
    log_warn "skipping $git_project_name"
    return
  }

  [ -z "$git_no_init_project_directory" ] && _project_directory_get_project_directory

  log_add_context "$git_project_name"

  _github_iterate || _github_iterate_cleanup

  cd $_pwd

  log_remove_context
  log_remove_context
}
